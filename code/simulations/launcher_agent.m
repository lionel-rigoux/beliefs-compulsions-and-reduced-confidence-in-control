function launcher_agent (allow_no_check)

    config = yaml.loadFile ('./config.yaml');

    % set up result directory
    if allow_no_check
        label = 'allow_no_check';
    else
        label = 'must_check';
    end
    resultdir = ['../../results/' label];
    [~,~] = mkdir(resultdir);

    % set up temp directory
    clear tempdir
    setenv('TMP','./temp/full/');
    [~,~] = mkdir(tempdir);
    
    
    % maximal number of simulations, in total
    maxNumberSimulations = 500;

    % worker timeout
    timeout = inf; 
    
    %% Loop over worlds
    for iWorld = 1 : config.N_WORLDS
        
        fprintf('generating agents for world %d\n------------------------------------\n',iWorld);
        
        %% Set up for collecting results and monitoring progress

        % look for existing results
        d0 = dir(sprintf('%s/full_%03d_0_*',resultdir,iWorld));
        d1 = dir(sprintf('%s/full_%03d_1_*',resultdir,iWorld));
        group = [numel(d0) numel(d1)];
        
        % all done, skip
        if all (group == config.N_AGENTS_PER_GROUP)
            fprintf('ctrl: %4.1f %%  comp: %4.1f %%\n', 100, 100);
            continue
        end
        
        % Start maxNumberSimulations workers in a parallel queue to 
        % generate a bunch of agents
        for idx = 1 : maxNumberSimulations
            workers(idx) = parfeval(@getAgent, 1, iWorld, allow_no_check);
        end
        
        % Ensure we do not leave any running worker on exit
        cancelFutures = onCleanup(@() cancel(workers));
      
        %% Collect and display results as they become available
        prog = 100 * group / config.N_AGENTS_PER_GROUP;
        fprintf('ctrl: %4.1f %%  comp: %4.1f %%\n', prog(1), prog(2));

        % Untill we have enough compulsive and non-compulsive agents
        while ~ all (group == config.N_AGENTS_PER_GROUP)
    
            % wait for the next agent to be generated
            try
                [status, a] = fetchNext(workers, timeout);
            catch err
                err
                err.cause{1}.message
                for ii = 1 : numel(err.cause{1}.stack)
                    err.cause{1}.stack(ii)
                end
                break
            end
            
            % If we got results
            if ~ isempty(status)
            
                % Assign agent to C or NC group
                flagComp = a.diagnostic.hasCompulsion;
                toSave = false;
            
                % If assignated group is incomplete, save
                if group(flagComp+1) < config.N_AGENTS_PER_GROUP
                    group(flagComp+1) = group(flagComp+1) + 1; 
                    toSave = true;
                end
    
                if toSave
                    possibleNames = arrayfun(@(k) sprintf ('full_%03d_%d_%02d.mat',iWorld, flagComp, k), 1:config.N_AGENTS_PER_GROUP, 'UniformOutput', false)';
                    dflag = dir(sprintf('%s/full_%03d_%d_*',resultdir,iWorld,flagComp));
                    existingNames = {dflag.name};
                    availableNames = setdiff(possibleNames,existingNames);
                    save (sprintf ('%s/%s', resultdir,availableNames{1}), 'a');
                end
    
            end
    
            % display progress
            prog = 100 * group / config.N_AGENTS_PER_GROUP;
            fprintf('ctrl: %4.1f %%  comp: %4.1f %%\n', prog(1), prog(2));
                      
        end
        
        % Now the simulation is complete, we can cancel the futures 
        cancel(workers);
    end

    %% Subroutine to try and generate a new agent
    %  ========================================================================
    function [a] = getAgent (iWorld, allow_no_check)

        %% load existing world
        l = load(sprintf('%s/../worlds/world_%03d.mat',resultdir,iWorld));
        
        %% generate valid agent
        isValid = false;
        while ~ isValid
            % start with world parameter set
            a = l.a_optimal.copy();
            a.allow_no_check = allow_no_check;
            % alter all subjective parameters
            a.changeSubjective ();
            % check policy
            a.simulate (config.N_SIMULATIONS,config.T_SIMULATIONS);
            a.diagnose();
            isValid = (a.diagnostic.doCheck | allow_no_check) & a.diagnostic.doWash;
        end      
    end
end


