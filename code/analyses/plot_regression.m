function [t,h_bar] = plot_regression(summary, paramName)


figure('Color','w');

%%

t1 = struct2table([summary(:).getDelta]);

value = t1.(paramName);
diagnostic = [summary(:).diagnostic];
delta = [summary(:).getDelta];
deltaParam = [delta.(paramName)];

t = append_row();

paramLabel = ['\Delta' strrep(paramName, '_',' ')];
%%
N = 9;
range = linspace(min(deltaParam),max(deltaParam),N);
idO = find(abs(range) == min(abs(range)));
range = unique([linspace(min(deltaParam)-eps,0,idO+1), linspace(0,max(deltaParam)+eps,N-idO+1)]);
[d,e] = discretize (deltaParam, range);

ste = @(z) std(z) / sqrt(numel(z));

clear hc ctype

compFlags = [[diagnostic.hasWashCompulsion]', [diagnostic.hasCheckCompulsion]', [diagnostic.hasMixedCompulsion]'];

% hasWashOnly = compFlags(:,1) & ~ (compFlags(:,2) | compFlags(:,3));
% hasCheckOnly = compFlags(:,2) & ~ (compFlags(:,1) | compFlags(:,3));
% hasMixedOnly = compFlags(:,3) & ~ (compFlags(:,1) | compFlags(:,2));
% hasMany = ~ (hasWashOnly | hasCheckOnly | hasMixedOnly);

for i = 1 : numel(e)-1
   ctype(1,i) = mean([diagnostic(d == i).hasWashCompulsion]);
   ctype(2,i) = mean([diagnostic(d == i).hasCheckCompulsion]);
   ctype(3,i) = mean([diagnostic(d == i).hasMixedCompulsion]);
   ctype(:,i) = ctype(:,i)/mean([diagnostic(d == i).hasCompulsion]);
   hc(i) = mean([diagnostic(d == i).hasCompulsion]);
   nBouts = [diagnostic(d == i).all_nBouts];
   pNum(i) = median(nBouts); 
   pNumDec(:,i) = quantile(nBouts,[.25 .75]);
   durBout = [diagnostic(d == i).all_durBouts_median] ;
   pDur(i) = median(durBout);
   pDurDec(:,i) = quantile(durBout,[.25 .75]); 
   propBout = [diagnostic(d == i).all_propBouts];
   pProp(i) = median(propBout); 
   pPropDec(:,i) = quantile(propBout,[.25 .75]); 
   update(i) = nanmedian([nan -[diagnostic(d == i).belief_washUpdate]]); 
   updateDec(:,i) = quantile([nan -[diagnostic(d == i).belief_washUpdate]],[.025 .975]); 
end

%hc(3,:) = hc(3,:) - sum(hc(1:2,:));

xx = (e(2:end)+e(1:end-1))/2;

%% has compulsion
subplot(2,3,1);
xline(0,':')
%yline(mean([diagnostic.hasCompulsion]),':')
hold on
%h_bar = bar(xx,hc);
h_bar = histogram('BinEdges',range,'BinCounts',hc);

%h_bar(1).FaceColor = colorsPOMDP(3);
%h_bar(2).FaceColor = colorsPOMDP(2);
%h_bar(3).FaceColor = (colorsPOMDP(2) + colorsPOMDP(3))/2;
%h_bar(4).FaceColor = [.3 .3 .3];
h_bar.FaceColor = [.3 .3 .3];
h_bar.LineStyle = 'none';
%h_bar.BarWidth = 1;

%xlim([min(xx), max(xx)])
axis tight
ylim([0,1])
set(gca,'YTick',[0 1], 'YTickLabel',[0, 100])
xlabel(paramLabel)
ylabel('% compulsive agents')

[rho, p] = bootstrap_spearman(deltaParam, [diagnostic.hasCompulsion]);
t = append_row(t, 'has compulsion', rho, p);

%% compulsion type

subplot(2,3,4);
htype = plot(xx,ctype);

htype(1).Color = colorsPOMDP(3);
htype(2).Color = colorsPOMDP(2);
htype(3).Color = (colorsPOMDP(2) + colorsPOMDP(3))/2;

xlim([min(xx), max(xx)])
xline(0,':')
set(gca,'YTick',[0 1], 'YTickLabel',[0 100])
xlabel(paramLabel)
ylabel('% compulsion type')

[rho, p] = bootstrap_spearman(deltaParam, [diagnostic.hasWashCompulsion]);
t = append_row(t, 'has wash compulsion', rho, p);
[rho, p] = bootstrap_spearman(deltaParam, [diagnostic.hasCheckCompulsion]);
t = append_row(t, 'has check compulsion', rho, p);
[rho, p] = bootstrap_spearman(deltaParam, [diagnostic.hasMixedCompulsion]);
t = append_row(t, 'has mixed compulsion', rho, p);

%% number bouts
subplot(2,3,2);

xxt = xx;
xxt(isnan(pNum)) = [];
pNumDec(:,isnan(pNum)) = [];

hf = fill([xxt fliplr(xxt)], [pNumDec(1,:) fliplr(pNumDec(2,:))],.9*[.99 1 1]);
hf.EdgeColor = 'none';
hold on
plot(xx,pNum','Color',[.9 0 0])
ylabel('# bouts')

xlim([min(xx), max(xx)])
xline(0,':')

xlabel(paramLabel)

nBoutsAll = mean([[diagnostic.mixed_nBouts]' [diagnostic.wash_nBouts]' [diagnostic.check_nBouts]'],2);

[rho, p] = bootstrap_spearman(deltaParam, nBoutsAll);
t = append_row(t, 'number bouts', rho, p);


%% duration bouts
subplot(2,3,3);

xxt = xx;
xxt(isnan(pDur)) = [];
pDurDec(:,isnan(pDur)) = [];

hf = fill([xxt fliplr(xxt)], [pDurDec(1,:) fliplr(pDurDec(2,:))],.9*[.99 1 1]);
hf.EdgeColor = 'none';
hold on
plot(xx,pDur','Color',[.9 0 0]);

xlim([min(xx), max(xx)])
xline(0,':')

xlabel(paramLabel)
ylabel('bout duration')


durBoutsAll = mean([[diagnostic.mixed_durBouts_median]' [diagnostic.wash_durBouts_median]' [diagnostic.check_durBouts_median]'],2);

[rho, p] = bootstrap_spearman(deltaParam, durBoutsAll);
t = append_row(t, 'duration bouts', rho, p);


%% belief update

subplot(2,3,5);

xxt = xx;
xxt(isnan(update)) = [];
updateDec(:,isnan(update)) = [];
hf = fill([xxt fliplr(xxt)], [updateDec(1,:) fliplr(updateDec(2,:))],.9*[.99 1 1]);
hf.EdgeColor = 'none';
hold on
plot(xx,update','Color',[.9 0 0])

xlim([min(xx), max(xx)])
xline(0,':')

xlabel(paramLabel)
ylabel('belief update')



%% proportion in bout
subplot(2,3,6);

xxt = xx;
xxt(isnan(pProp)) = [];
pPropDec(:,isnan(pProp)) = [];

hf = fill([xxt fliplr(xxt)], [pPropDec(1,:) fliplr(pPropDec(2,:))],.9*[.99 1 1]);
hf.EdgeColor = 'none';
hold on
plot(xx,pProp','Color',[.9 0 0])
ylabel('% actions in bouts')

xlim([min(xx), max(xx)])
xline(0,':')

set(gca, 'YLim', [0 1])
set(gca,'YTick',[0 1],'YTickLabel',[0,100])
xlabel(paramLabel)

propBoutsAll = mean([[diagnostic.mixed_propBouts]' [diagnostic.wash_propBouts]' [diagnostic.check_propBouts]'],2);

[rho, p] = bootstrap_spearman(deltaParam, propBoutsAll);
t = append_row(t, 'proportion in bouts', rho, p);

% %%
% subplot(2,3,5);
% 
% scatter(value,-[diagnostic.belief_washUpdate],'k.'); 
% h=refline; h.Color=[.9 0 0]; h.LineWidth=2;
% xlim([-.75, .75])
% set(gca,'XTick',[-.7 0 .7])
% set(gca,'YTick',[0])
% xlabel(paramLabel)
% ylabel('belief update')
% 
% 
[rho, p] = bootstrap_spearman(deltaParam, -[diagnostic.belief_washUpdate]);
t = append_row(t, 'belief update', rho, p);

end

function t = append_row(t, redoutName, rho, p)

fprintpval = @(v) printval (v, 'signed', false, 'stars', true);

if nargin == 0
    t = [];
    v1 = {};
    v2 = {};
    v3 = {};
else
    v1 = string(redoutName);
    v2 = string(sprintf('%0.3f', rho));
    v3 = string(fprintpval(p));
end
    ttemp = table( ...
        v1, ...
        v2, ...
        v3, ...
        'VariableNames',{'readout','Spearmann rho','p-value'});
    t = [t; ttemp];
end