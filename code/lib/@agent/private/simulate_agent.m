function results = simulate_agent (real_world, belief)

    try
        results = agent.solvePOMDP (belief);
        
        results.believed_pomdp = results.pomdp;
        results.pomdp = agent.writePOMDP (real_world, 'struct');
        
        results.simulation = agent.simulatePOMDP (results);

        %results.diagnostic = diagnose_agent (results);    

        results.options.belief = belief ;
        results.options.real_world = real_world ;
        %results.options.delta = getDelta (belief, real_world);

    catch err
        results = nan;
        disp(err);
        fprintf('*** cannot compute \n');
    end
end