function obj = diagnose (obj)
% this function analyse the simulated behavior of an agent and compute
% diagnostics statistics

% check for compulsions

% cook = 1
% check = 2
% wash = 3

%% concatenate simulations

% copy to avoid altering the original simuls
s = obj.simulation;

% add nan at the end of each sequence
s = arrayfun(@(si) structfun(@(f) [f nan]',si,'UniformOutput',false),s);

% concatenate
t = arrayfun(@(si) struct2table(si),s, 'UniformOutput',false);
s = table2struct(vertcat(t{:}), 'ToScalar',true);

%% compute stats
stats = struct;

% compulsive bouts
stats = countBouts (stats, s.action, 'wash');
stats = countBouts (stats, s.action, 'check');
stats = countBouts (stats, s.action, 'mixed');
stats = countBouts (stats, s.action, 'all');

% assess repetition probability
stats = getContingencies (stats, s.action);

% action chaining
stats = computeFrequencies (stats, s);

% beliefs
stats = averageBeliefs (stats, s);
stats = beliefUpdate (stats, s);

% as structre
obj.diagnostic = stats;

obj.diagnostic.doCheck = obj.diagnostic.freq_check > 0; 
obj.diagnostic.doWash = obj.diagnostic.freq_wash > 0; 
obj.diagnostic.doCook = obj.diagnostic.freq_cook > 0; 
obj.diagnostic.hasWashCompulsion = obj.diagnostic.wash_nBouts > 0;
obj.diagnostic.hasCheckCompulsion = obj.diagnostic.check_nBouts > 0;
obj.diagnostic.hasMixedCompulsion = obj.diagnostic.mixed_nBouts > 0;
obj.diagnostic.hasCompulsion = obj.diagnostic.all_nBouts > 0;

end

% =========================================================================
% Compute sufficient statistics of visited state, beliefs, and outcomes
% =========================================================================
function stats = computeFrequencies (stats, simulation)
    % different frequencies
    stats.freq_clean = nanmean(simulation.state == 1);
    stats.freq_cook = nanmean(simulation.action == 1);
    stats.freq_check = nanmean(simulation.action == 2);
    stats.freq_wash = nanmean(simulation.action == 3);

    stats.freq_obs_clean_ifclean = mean(simulation.observation(simulation.state == 1) == 1) ;
    stats.freq_obs_dirty_ifdirty = mean(simulation.observation(simulation.state == 2) == 2) ;
    
    stats.belief_median = nanmedian(simulation.belief);
    stats.belief_mean = nanmean(simulation.belief);
    stats.belief_var = nanvar(simulation.belief);
    
    stats.belief_ifclean_median = nanmedian(simulation.belief(simulation.state==1));
    stats.belief_ifclean_mean = nanmean(simulation.belief(simulation.state==1));
    stats.belief_ifclean_var = nanvar(simulation.belief(simulation.state==1));

    stats.belief_ifdirty_median = nanmedian(simulation.belief(simulation.state==2));
    stats.belief_ifdirty_mean = nanmean(simulation.belief(simulation.state==2));
    stats.belief_ifdirty_var = nanvar(simulation.belief(simulation.state==2));
    
    stats.reward_mean = nanmean(simulation.reward(2:end-1));
    stats.reward_var = nanvar(simulation.reward(2:end-1));
    
    stats.utility_mean = nanmean(simulation.utility(1:end-1));
    stats.utility_var = nanvar(simulation.utility(1:end-1));
    
    stats.utility_cook = nanmean(simulation.utility(simulation.action == 1));
    stats.utility_check = nanmean(simulation.utility(simulation.action == 2));
    stats.utility_wash = nanmean(simulation.utility(simulation.action == 3));

    
end

% =========================================================================
% Find compulsive bouts (repeated actions)
% =========================================================================
function stats = countBouts (stats, a, type)
    % convert actions to string
    a(isnan(a)) = 0;
    s = string(a(1:end-1));
    s = [s{:}];
    
    % cut sequences into bouts
    switch type
        case 'wash'
            delimiter = {'1','2'}; % keep only chained wash
        case 'check'
            delimiter = {'1','3'}; % keep only chained checks
        case {'mixed', 'all'}
            delimiter = {'1'}; % keep all non cook actions
    end
    bouts = strsplit (s, delimiter);
    
    % remove cross simul bouts
    bouts(cellfun(@(b) ismember('0',b), bouts)) = [];
    
    % flag mixed bouts
    isMixed = cellfun(@(b) numel(unique(b)) == 2, bouts);
    
    % remove pure bouts if looking for mixed only
    if strcmp (type, 'mixed')
        bouts(~ isMixed) = [];
        isMixed(~ isMixed) = [];
    end

    % count bouts duration
    boutLength = cellfun (@numel, bouts);
    
    % do not count first action(s)
    compulsionLength = boutLength - 1 - isMixed;
    compulsionLength = compulsionLength(compulsionLength > 0);

    % characterize bouts
    %stats.([type '_bouts']) = compulsionLength;
    if isempty (compulsionLength)
        stats.([type '_nBouts']) = 0;
        stats.([type '_durBouts_mean']) = 0;
        stats.([type '_durBouts_median']) = 0;
        stats.([type '_totBouts']) = 0;
        stats.([type '_minDurBouts']) = 0;
        stats.([type '_propBouts']) = 0; 
    else
        stats.([type '_nBouts']) = numel(compulsionLength);
        stats.([type '_durBouts_mean']) = mean(compulsionLength);
        stats.([type '_durBouts_median']) = median(compulsionLength);
        stats.([type '_totBouts']) = sum(compulsionLength);
        stats.([type '_minDurBouts']) = min(compulsionLength);
        stats.([type '_propBouts']) = sum(compulsionLength) / sum (boutLength);
    end
    
end

% =========================================================================
% Calculate action repetition
% =========================================================================
function stats = getContingencies (stats, a)

    act_labels = {'cook', 'check', 'wash'};

    % probabilies of repetition
    % ---------------------------------------------------------------------
    % initialize
    contigencies = zeros(3);
    
    % count action chainings
    prev_action = a(1);
    for t = 2 : numel (a)-1
        action = a(t);
        if ~ isnan(action) && ~ isnan(prev_action)
            contigencies(action, prev_action) = contigencies(action, prev_action) + 1;
        end
        prev_action = action;
    end
    
    % normalize
    for i = 1 : 3
        contigencies(:,i) = contigencies(:,i)/(sum(contigencies(:,i))+eps);
    end
    
    % store flat
    for prev_action = 1 : 3
        for next_action = 1 : 3
            label = sprintf('p_transition_%s_%s', act_labels{prev_action}, act_labels{next_action});
            stats.(label) = contigencies(next_action, prev_action);
        end
    end
    
    % action length
    % ---------------------------------------------------------------------
   
    for iAct = 1 : 3
        % convert actions to string
        a(isnan(a)) = 0;
        s = string(a(1:end-1));
        s = [s{:}];
        delimiter = split(num2str(setdiff(1:3,iAct)));
        bouts = strsplit (s, delimiter);
        bouts(cellfun(@(b) ismember('0',b), bouts)) = []; 
        boutLength = cellfun (@numel, bouts);
        boutLength = boutLength(boutLength>0);
        if isempty(boutLength)
            boutLength = 0;
        end
        
        stats.(['repetition_' act_labels{iAct} '_min']) = min(boutLength);
        stats.(['repetition_' act_labels{iAct} '_max']) = max(boutLength);
        stats.(['repetition_' act_labels{iAct} '_mean']) = mean(boutLength);
        stats.(['repetition_' act_labels{iAct} '_median']) = median(boutLength);
        stats.(['repetition_' act_labels{iAct} '_Q1']) = quantile(boutLength, .25);
        stats.(['repetition_' act_labels{iAct} '_Q3']) = quantile(boutLength, .75);
    end
    
end

% =========================================================================
% Compute beliefs sufficient stats
% =========================================================================
function stats = averageBeliefs (stats, simul)

    stats.belief_mean = nanmean(simul.belief);
    stats.belief_median = nanmedian(simul.belief);
    
    stats.belief_cook = nanmean(simul.belief(simul.action == 1));
    stats.belief_check = nanmean(simul.belief(simul.action == 2));
    stats.belief_wash = nanmean(simul.belief(simul.action == 3));
end

% =========================================================================
% Compute belief update after wash
% =========================================================================
function stats = beliefUpdate (stats, simul)

    idxWash = find(simul.action(1:end-1) == 3);
    
    initialBelief = simul.belief(idxWash);
    nextBelief = simul.belief(idxWash+1);
    
    stats.belief_washUpdate = nanmean(nextBelief - initialBelief);
end
