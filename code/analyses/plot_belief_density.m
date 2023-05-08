function [h,t_diagnostic] = plot_belief_density(summary)

    diagnostic = [summary.diagnostic];
    
    isCompulsive = [diagnostic.hasCompulsion];
    
    clf
    subplot(1,2,1)
    hold on


h(1,1) = plot_density([diagnostic(isCompulsive).belief_cook]);
h(1,2) = plot_density([diagnostic(~isCompulsive).belief_cook]);

h(2,1) = plot_density([diagnostic(isCompulsive).belief_check]);
h(2,2) = plot_density([diagnostic(~isCompulsive).belief_check]);


h(3,1) = plot_density([diagnostic(isCompulsive).belief_wash]);
h(3,2) = plot_density([diagnostic(~isCompulsive).belief_wash]);

for i = 1:3
    h(i,1).Color = colorsPOMDP(i);
    h(i,2).Color = colorsPOMDP(i);
    h(i,1).LineStyle = '--';
end
[h.LineWidth] = deal(2.5);



xlabel('state belief')
set(gca,'XTick',[0 .5 1],'XTickLabel',{'surely clean','uncertain','surely diry'})
ylabel('density')
set(gca,'YTick',0)
set(gcf,'Color','w')



%%

subplot(1,2,2)
clear h
hold on

h(1) = plot_density([diagnostic(isCompulsive).belief_median]);
h(2) = plot_density([diagnostic(~isCompulsive).belief_median]);

h(1).Color = .2*[1 1 1];
h(2).Color = .2*[1 1 1];
h(1).LineStyle = '--';
[h.LineWidth] = deal(2.5);

xlabel('state belief')
set(gca,'XTick',[0 .5 1],'XTickLabel',{'surely clean','uncertain','surely diry'})
ylabel('density')
set(gca,'YTick',0)
set(gcf,'Color','w')

%%
t_diagnostic = struct2table(diagnostic);
t_diagnostic = t_diagnostic(:, {'belief_cook','belief_check','belief_wash','belief_median','hasCompulsion'});

end

function h = plot_density(z)
    
    N = 30;
    x = linspace(0,1,N);
    [counts,~,~] = histcounts(z,N,'Normalization','pdf');
    h = plot(x,counts);
end