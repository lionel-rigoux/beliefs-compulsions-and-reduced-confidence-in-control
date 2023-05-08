function [g, t] = plot_update (summary)

diagnostic = [summary.diagnostic];

g = gramm (...
    'x', categorical([diagnostic.hasCompulsion]), ...
    'y',-[diagnostic.belief_washUpdate], ...
    'color',[diagnostic.hasCompulsion] ...
    );
g.stat_summary('type','std','geom',{'bar','errorbar'});
g.set_names('x','Group','y','Belief update');
g.axe_property('XTickLabel',{'NC','C'});

g.set_color_options('map',[.3 .3 .3; .7 .7 .7]);
g.no_legend();
g.draw;

t = table(-[diagnostic.belief_washUpdate]', [diagnostic.hasCompulsion]','VariableNames',{'Belief update','hasCompulsion'});