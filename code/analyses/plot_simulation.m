function plot_simulation(agent)

S = 50 ;
n = 500;

hold on;
for iS = 1:S
    
    simul =  agent.simulation(iS);
    
    x = 1:n ;
    y = -2*iS*ones(1,n);
    
    state = simul.state(1:n)-1;
    fill([x fliplr(x)],[y-.15*state fliplr(y+.15*state)]-.8,.4*[1 1 1],'edgealpha',0)
    scatter(x,y,30,simul.action(1:n),'filled')
    colormap(gca,colorsPOMDP());

    axis off;
    %axis equal

end


f=gcf;
f.Color = 'w';
