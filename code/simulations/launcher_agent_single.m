function launcher_agent_single (paramName, allow_no_check)

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
    setenv('TMP','./temp/single/');
    [~,~] = mkdir(tempdir);
    
    % maximal number of simulations, in total
    maxNumberSimulations = 200;
    % worker timeout
    timeout = inf; 
    
    for iWorld = 1 : config.N_WORLDS
        
        fprintf('generating agents for world %d\n------------------------------------\n',iWorld);
        
        %% Set up for collecting results and monitoring progress
        
        % look for existing results
        d = dir(sprintf('%s/%s_%03d_*',resultdir,paramName,iWorld));
        group = [numel(d)];
        
        % all done, skip
        if all (group == config.N_AGENTS_PER_GROUP)
            fprintf('%s: %4.1f %%\n', paramName, 100);
            continue
        end
        
        %% Start maxNumberSimulations workers in a parallel queue
        for idx = 1 : maxNumberSimulations
            workers(idx) = parfeval(@getAgent, 1, iWorld, paramName, allow_no_check);
        end
        
        % Ensure we do not leave any running worker on exit
        cancelFutures = onCleanup(@() cancel(workers));
    
        %% Collect and display results as they become available
        prog = 100 * group / config.N_AGENTS_PER_GROUP;
        fprintf('%s: %4.1f %%\n', paramName, prog);
        while ~ all (group == config.N_AGENTS_PER_GROUP)
    
            % wait for agent to be generated
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
            
                % if the group is not complete, save
                toSave = false;
            
                if group < config.N_AGENTS_PER_GROUP
                    group = group + 1; 
                    toSave = true;
                end
                
                if toSave
                    possibleNames = arrayfun(@(k) sprintf ('%s_%03d_%02d.mat',paramName, iWorld, k), 1:config.N_AGENTS_PER_GROUP, 'UniformOutput', false)';
                    dflag = dir(sprintf('%s/%s_%03d_*',resultdir,paramName, iWorld));
                    existingNames = {dflag.name};
                    availableNames = setdiff(possibleNames,existingNames);
                    save (sprintf ('%s/%s', resultdir, availableNames{1}), 'a');
                end
    
            end
    
            prog = 100 * group / config.N_AGENTS_PER_GROUP;
            fprintf('%s: %4.1f %%\n', paramName, prog);
                      
        end
        
        % Now the simulation is complete, we can cancel the futures 
        cancel(workers);
    end

    %% Subroutine to try and generate a new agent
    %  ========================================================================
    function [a] = getAgent (iWorld, paramName, allow_no_check)
    
        %% load existing world
        l = load(sprintf('%s/../worlds/world_%03d.mat',resultdir,iWorld));
        
        %% generate valid agent
        isValid = false;
        while ~ isValid
            % start with world parameter set
            a = l.a_optimal.copy();
            a.allow_no_check = allow_no_check;
            % alter subjective parameters of interest
            a.changeSubjective (paramName);
            % check policy
            a.simulate (config.N_SIMULATIONS,config.T_SIMULATIONS);
            a.diagnose();
            isValid = (a.diagnostic.doCheck | allow_no_check) & a.diagnostic.doWash;
        end      
    end
end


