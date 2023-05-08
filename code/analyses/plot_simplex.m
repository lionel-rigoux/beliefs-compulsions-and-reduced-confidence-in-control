function plot_simplex(summary)

params = [summary.params];

params = [params.subjective];

costs(:,1) = -[params.value_check];
costs(:,2) = -[params.value_wash];
costs(:,3) = -[params.value_cook_dirty];

diagnostic = [summary.diagnostic];
flag.compulsion = [diagnostic.hasCompulsion];
flag.checkCompulsion = [diagnostic.hasCheckCompulsion];
flag.washCompulsion = [diagnostic.hasWashCompulsion];
flag.mixedCompulsion = [diagnostic.hasMixedCompulsion];


subplot(1,4,1)
subtitle('NC')
myScatter(costs,~flag.compulsion)

subplot(1,4,2)
subtitle('C - check, no wash')
myScatter(costs,flag.checkCompulsion & ~ flag.washCompulsion)

subplot(1,4,3)
subtitle('C - wash, no check')
myScatter(costs,flag.washCompulsion & ~ flag.checkCompulsion)

subplot(1,4,4)
subtitle('C - mixed only')
myScatter(costs,flag.mixedCompulsion & ~ flag.washCompulsion & ~ flag.checkCompulsion)


end

function myScatter(c,f)
cla
c = c(f,:);
s = simplex;
s.plot_axis
if ~ isempty(c)
    h = s.scatter(c);
    %h.CData = double(flag.compulsion)
    h.MarkerFaceAlpha = .2;
    h.MarkerFaceColor = [0 0 0];
    cm = geomean(c);
    cm = cm / sum(cm);
    s.scatter(cm,'MarkerFaceColor',[.9 .7 .7], 'MarkerEdgeColor','none');
end
s.scatter([1 0 0],'MarkerFaceColor',[.9 0 0]);
s.scatter([0 1 0],'MarkerFaceColor',[0 0 .9]);
s.scatter([0 0 1],'MarkerFaceColor',[0 .9 0]);

end

