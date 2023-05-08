function [t,t_Ai] = analyse_between_group(summary)

t1 = struct2table([summary(:).getDelta]);
t1(:,'value_cook_clean') = [];


diagnostic = [summary(:).diagnostic];
t1.hasCompulsion = [diagnostic.hasCompulsion]';

t = t1(:,[1 6 3 7 5 4 8 2 12]);
t_Ai = t1(:,[1 9 3 10 5 4 11 2 12]);
%%

t.Properties.VariableNames = strrep(t.Properties.VariableNames, 'prob_','p_');

labels = t.Properties.VariableNames(1:end-1);


t_mean = grpstats(t,'hasCompulsion');
t_mean = t_mean(:,3:end);
t_stdp = grpstats(t,'hasCompulsion',@(x) quantile(x,.25));
t_stdp = t_stdp(:,3:end);
t_stdm = grpstats(t,'hasCompulsion',@(x) quantile(x,.75));
t_stdm = t_stdm(:,3:end);
theta = linspace(0,2*pi,numel(labels)+1);


colors = {[0 1 0], [1 0 0]};

for iG = 1:2

    tmpHandle = subplot(1,2,iG);
	h = polaraxes('Units',tmpHandle.Units,'Position',tmpHandle.Position);
    delete(tmpHandle);
    
h.ThetaAxis.TickValues = theta * 360 / (2 * pi);
h.ThetaAxis.TickLabels = labels;
h.RAxis.TickValues = 0;
hold on

polarplot(theta,lineCirc(t_mean,iG),'Color',.5*colors{iG},'LineWidth',3);
polarplot(theta,lineCirc(t_stdp,iG) ,'Color',.8*colors{iG});
polarplot(theta,lineCirc(t_stdm,iG) ,'Color',.8*colors{iG});

rlim([-.75 .35]);

    if iG == 1
        subtitle('Not Compulsive');
    else
        subtitle('Compulsive');
    end

end
% 
% p.wilcoxon = varfun(@(x) bootstrap_wilkoxon(x,t.hasCompulsion), t);
% p.ttest = varfun(@(x) bootstrap_ttest2(x,t.hasCompulsion), t);
% 
% p_Ai.wilcoxon = varfun(@(x) bootstrap_wilkoxon(x,t_Ai.hasCompulsion), t);
% p_Ai.ttest = varfun(@(x) bootstrap_ttest2(x,t_Ai.hasCompulsion), t);




function l = lineCirc(t,i)
    l = [t{i,:}, t{i,1}];

