function plot_simulation(agent)


hold on;
for iS = 1:min(numel(agent.simulation),10)
    
    simul =  agent.simulation(iS);
    
    n = min (numel(simul.action),200);
    x = 1:n ;
    y = -2*iS*ones(1,n);
    
    state = simul.state(1:n)-1;
    fill([x fliplr(x)],[y-.15*state fliplr(y+.15*state)]-.8,.4*[1 1 1],'edgealpha',0)
    scatter(x,y,30,simul.action(1:n),'filled')
    colormap(gca,colorsPOMDP());

end

set(gca,'Clim',[1 3])
axis off;

f=gcf;
f.Color = 'w';
