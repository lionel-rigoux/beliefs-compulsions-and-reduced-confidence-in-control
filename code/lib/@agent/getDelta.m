function delta = getDelta (obj, inPercentage)

if numel(obj) > 1
    delta = arrayfun(@getDelta, obj);
    return;
end

if nargin < 3
    inPercentage = false;
end

world = obj.params.world;
if ~ isempty (obj.params.subjective)
    subjective = obj.params.subjective;
else
    subjective = world;
end

f = fieldnames(world);
for iF=1:numel(f)
    delta.(f{iF}) = subjective.(f{iF}) - world.(f{iF});
    
    if inPercentage
        delta.(f{iF}) = delta.(f{iF}) ./ world.(f{iF});
    end
        
end

delta = compute_compositional_delta(delta, world, subjective);


end



function delta = compute_compositional_delta(delta, world, subjective)

x = [world.value_cook_dirty, world.value_check, world.value_wash];
y = [subjective.value_cook_dirty, subjective.value_check, subjective.value_wash];

clr_x = log(-x / geomean(-x));
clr_y = log(-y / geomean(-y));

clr = clr_y - clr_x;

delta.value_wash_Ai = - clr(3);
delta.value_check_Ai = - clr(2);
delta.value_cook_dirty_Ai = - clr(1);

end
