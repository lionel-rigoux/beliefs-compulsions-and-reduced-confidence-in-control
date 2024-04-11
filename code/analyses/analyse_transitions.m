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
