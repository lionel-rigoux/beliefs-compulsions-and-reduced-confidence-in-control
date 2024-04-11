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
colormap(p.Parent,flipud(colormap(p.Parent,'bone')));
p.EdgeCData = G.Edges.Weight' ;

p.EdgeAlpha = 1 ;
p.ArrowSize = 20 ;

set(gca,'CLim',[-0 1])

%colorbar

end