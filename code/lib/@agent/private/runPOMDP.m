function results=runPOMDP(delusion)


real_world=defaultPOMDP();

%%

if ~exist('delusion','var')
    delusion = struct;
end

pomdp_parameters = fieldnames(real_world);
for iP=1:numel(pomdp_parameters)
        current_parameter = pomdp_parameters{iP} ;
        if isfield(delusion,current_parameter)
            belief.(current_parameter) =  delusion.(current_parameter);
        else
            belief.(current_parameter) = real_world.(current_parameter) ;
        end
end
%%

config = writePOMDP(belief,'text');
results=solvePOMDP(config);


%%



results.believed_pomdp = results.pomdp;
results.pomdp = writePOMDP(real_world,'struct');

%%

results.simulation=simulatePOMDP(results);
results=suffStatsPOMDP(results);

