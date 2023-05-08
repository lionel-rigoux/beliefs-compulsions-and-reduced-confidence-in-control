function [t_transitions, h] = analyse_transitions(summary)

figure('Color','w');

for iGroup = 1 : 2
    
    diagnostic = [summary.diagnostic];
    if iGroup == 1
        flag = ~[diagnostic.hasCompulsion];
    else
        flag = [diagnostic.hasCompulsion];
    end
    summary_group = summary(flag);
    
    for iA = 1 : numel(summary_group)
        m(:,:,iA) = diagnostic2matrix(summary_group(iA).diagnostic);
    end
    
    t{iGroup} = mean(m,3);
    
    subplot(1,2,iGroup);
    h = plot_trigram(t{iGroup});
    if iGroup == 1
        subtitle('Not Compulsive');
    else
        subtitle('Compulsive');
    end

end

%%

diagnostic = struct2table([summary(:).diagnostic]);
t_transitions = diagnostic(:,startsWith(diagnostic.Properties.VariableNames,'p_transition'));
t_transitions.hasCompulsion = diagnostic.hasCompulsion;

t_transitions.Properties.VariableNames = strrep(t_transitions.Properties.VariableNames, 'p_transition_','p_');


%%

%%



end

function p = plot_trigram(t)

G = digraph();
G = addnode(G,{'cook','check','wash'});

for a1=1:3
    for a2=1:3
        if t(a2,a1)>0
        G = addedge(G,a1,a2,t(a2,a1));
        end
    end
end


LWidths = 5*(G.Edges.Weight/max(G.Edges.Weight));

x = 1*[0 1 .5];
y = 1*[0 0 .7] ;


p = plot(G,'XData',x,'YData',y,'EdgeLabel',{},'LineWidth',8);

% figure

% axis
axis equal
box off
axis off
xlim([-.3 1.3])
ylim([-.3 1.3])

% nodes
p.MarkerSize = 30 ;
p.NodeColor = colorsPOMDP() ;
p.NodeLabel = {};

% edges
colormap(gcf,flipud(colormap('bone')));
p.EdgeCData = G.Edges.Weight' ;

p.EdgeAlpha = 1 ;
p.ArrowSize = 20 ;

set(gca,'CLim',[-0 1])

%colorbar

end
%%
function m = diagnostic2matrix(d)

    labels = {'cook','check','wash'};
    
    for l1 = 1 : 3
        for l2 = 1 : 3
            fname = sprintf('p_transition_%s_%s',labels{l1}, labels{l2});
            m(l2,l1) = d.(fname);
        end
    end
end
