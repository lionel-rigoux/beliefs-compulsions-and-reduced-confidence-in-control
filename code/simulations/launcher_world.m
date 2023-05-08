function launcher_world ()

    config = yaml.loadFile ('./config.yaml');
    
    % set up result directory
    resultdir = '../../results/worlds';
    [~,~] = mkdir(resultdir);

    % setup temporary directory
    clear tempdir
    setenv('TMP','./temp/worlds/');
    [~,~] = mkdir(tempdir);
    
    % worker timeout
    timeout = inf;
    
    
    %% Start workers to get worlds
    for idx = 1 : config.N_WORLDS
        workers(idx) = parfeval(@getWorld, 0, idx, false);
    end
    % Ensure we do not leave any running worker on exit
    cancelFutures = onCleanup(@() cancel(workers));
    
    
    %% Collect and display results as they become available
    complete = false;
    counter = 0;
    while ~ complete
        % wait for next worker
        [status] = fetchNext(workers, timeout);
    
        % If we got results, count
        if ~ isempty(status)
    	    counter = counter + 1;
        end
        fprintf('worlds: %4.1f %%\n', 100*counter/config.N_WORLDS);
        
        % Stop if all groups complete
        complete = counter == config.N_WORLDS;             
    end
    
    % Now the simulation is complete, we can cancel the futures 
    cancel(workers);
    
    %% Subroutine to try and generate a new world
    %  ========================================================================
    function [] = getWorld (iWorld, allow_no_check)
    
        %% Check if target file already exist
        filename = sprintf('%s/world_%03d',resultdir,iWorld);
    
        if exist([filename '.mat']) == 2
            fprintf('world %d already exist\n', iWorld);
            return
        end
        
        %% Find world:    
        % try parameter sets until the optimal policy fits the inclusion criteria
        isValid = false;
        while ~isValid
            a_optimal = agent(false);
            a_optimal.simulate (config.N_SIMULATIONS,config.T_SIMULATIONS);
            a_optimal.diagnose();
            isValid = ~ a_optimal.diagnostic.hasCompulsion & (a_optimal.diagnostic.doCheck | allow_no_check) & a_optimal.diagnostic.doWash;
        end
        
        %% Save results
        save (filename, 'a_optimal');
        
    end

end


    