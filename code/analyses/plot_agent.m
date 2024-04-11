function plot_agent (agent)

% figure
figure('Color',[1 1 1]                  , ...
       'WindowStyle','normal'           , ...
       'DockControls','off'             , ...
       'MenuBar','none'                 , ...
       'ToolBar','none'                 , ...
       'Position', [200 200 600 800]        )

% colors
color.wash   = [0.3 0.3 1  ];
color.check  = [1   0.3 0.3];
color.cook   = [0.5 0.8 0.1];

color.clean   = [0.7 0.7 0.7];
color.dirty   = [0.3 0.3 0.3];

color.clean_nothing = [0.7 0.9 0.7];
color.clean_dirt    = [0.7 0.7 0.9];
color.dirty_nothing = [0.3 0.5 0.3];
color.dirty_dirt    = [0.3 0.3 0.5];

%find labels
if ~ isempty (agent.pomdp.subjective)
    pomdp = agent.pomdp.subjective;
else
    pomdp = agent.pomdp.world;
end

for i=1:pomdp.nrActions
    labels_action{i} = strtrim(pomdp.actions(i,:));
end

for i=1:pomdp.nrStates
    labels_state{i} = pomdp.states(i,:);
    for j=1:pomdp.nrObservations
        labels_observation{(i-1)*pomdp.nrObservations+j} = [labels_state{i} '/' pomdp.observations(j,:)];
    end
end


% plot value function
belief_space = linspace (0, 1, 1e3); 

% compute value function for each alpha vector
action_value = nan (numel (belief_space), 3);
for iAction = 1:3
for iBelief = 1 : numel (belief_space)
    alpha_values = [1 - belief_space(iBelief),  belief_space(iBelief)] * agent.policy.value(:, agent.policy.action == iAction);
    if ~ isempty (alpha_values)
        action_value(iBelief, iAction) = max (alpha_values) ;
    end
end
end


ax_value = subplot(6,2,[1 3]);
plot(belief_space, action_value','LineWidth',3) ;
title('Value function');
legend(labels_action,'Location','SouthWest');
set(gca,'XTick',[0 1], 'XTickLabel',{'clean','dirty'})
ylabel('action value');
[ax_value.Children.LineWidth] = deal(3);
recolor(ax_value.Children) ;


% plot policy
ax_belief_policy = subplot(6,2,5);
[~,act] = max(action_value');
imagesc(act);
colormap(ax_belief_policy,[color.cook; color.check; color.wash]) ;
title('Optimal policy')
set(ax_belief_policy,'XTick',[1 numel(belief_space)], 'XTickLabel',{'clean','dirty'})
set(ax_belief_policy,'YTick',[])
set(ax_belief_policy,'Clim',[1 3])


% plot transitions
for a1 = 1:3
    for a2 = 1:3
        t(a2,a1) = agent.diagnostic.(['p_transition_' labels_action{a1} '_' labels_action{a2}]);
    end
end
ax_transitions = subplot(6,2,[2 4 6]);
plot_trigram(t);
title ('Action transitions')
cbar = colorbar(ax_transitions,'southoutside');
cbar.Label.String = 'transition probability';
axis equal

% plot simulations

ax_simul = subplot(6,2,7:12);
plot_simulation(agent)
ax_simul.Position(2) = .06;
title ("Simulations")

    function recolor(elems)
        for iE =1:numel(elems)
            try
                c = color.(elems(iE).DisplayName) ;
                try, elems(iE).Color = c; end
                try, elems(iE).EdgeColor = c; end
                try, elems(iE).FaceColor = c; end
            end
        end
    end

end