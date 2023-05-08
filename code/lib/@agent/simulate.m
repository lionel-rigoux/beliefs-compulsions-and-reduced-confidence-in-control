function obj = simulate (obj, N, T)


BURNIN = 0;%100;
%T = 2000 + BURNIN;
%N = 100;

policy = obj.policy;
pomdp = obj.pomdp.world;

if ~ isempty (obj.pomdp.subjective)
    pomdp_subjective = obj.pomdp.subjective;
else
    pomdp_subjective = obj.pomdp.world;
end
    

%% ------------------------------------------------------------------------
%   Simulation of the POMDP under the optimal policy
%% ------------------------------------------------------------------------

simulation = struct ( ...
    'state', nan(1,T), ...
    'belief', nan(1,T), ...
    'action', nan(1,T), ...
    'observation', nan(1,T), ...
    'reward', nan(1,T), ...
    'utility', nan(1,T) ...
);

simulation = repmat(simulation,N,1);


for repet = 1 : N
    

    state = nan(1,T);
    belief= nan(1,T);
    action= nan(1,T);
    observation= nan(1,T);
    reward= nan(1,T);
    utility= nan(1,T);
    
    
    belief(1)      = rand();
    state(1)       = 1+(belief(1)>.5);
    
    for t = 1 : T
        
        belief_vec = [1-belief(t) belief(t)]'; 
        
        % choose action according to beliefs
        % decide best action
        v_action = policy.value' * belief_vec;        
        utility(t) = max(v_action);
        action(t) = policy.action(v_action == utility(t));

        % update real world accordingly
        next_state_mdp_distrib = pomdp.transition(:,state(t),action(t)) ;
        next_state_mdp_distrib = next_state_mdp_distrib/sum(next_state_mdp_distrib);
        state(t+1) = find(cumsum(next_state_mdp_distrib) > rand,1) ;
        
        % find corresponding observation
        observation_distrib = pomdp.observation(state(t+1),action(t),:) ;
        observation(t+1) = find(cumsum(observation_distrib) > rand,1) ;
        
        % find corresponding reward
        reward(t) = pomdp.reward3(state(t+1),state(t),action(t)) ;
        
        % update belief
        prior_next = pomdp_subjective.transition(:,:,action(t)) * belief_vec ;
        posterior_next = pomdp_subjective.observation(:,action(t),observation(t+1)) .* prior_next;
        belief_distrib = posterior_next / sum(posterior_next);
        belief(t+1) = belief_distrib(2);
                
    end
    
    % store
    
    simulation(repet).state       = state(BURNIN+1:T);
    simulation(repet).belief      = belief(BURNIN+1:T);
    simulation(repet).action      = action(BURNIN+1:T);
    simulation(repet).observation = observation(BURNIN+1:T);
    simulation(repet).reward      = reward(BURNIN+1:T);
    simulation(repet).utility     = utility(BURNIN+1:T);
    
    
end

obj.simulation = simulation;





