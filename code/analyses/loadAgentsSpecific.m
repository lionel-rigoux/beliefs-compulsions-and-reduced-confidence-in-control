function summary = loadAgentsSpecific (paramName, prefix)

fprintf('Summarizing partial simulations for %s (%s)...\n',paramName,prefix);

% find all files corresponding to the contxt
resultDir = sprintf('../../results/%s/', prefix);

d = dir ([resultDir paramName '_*']);
for i = 1 : numel (d)
    % load result file
    fprintf('%0.3f %%\n',100*i/numel(d))
    
    l = load ([resultDir d(i).name]);
    l.a.simulation = [];
    l.a.log = [];

    % organize
    [id] = sscanf (d(i).name, [paramName '_%d_%d.mat']);

    summary{id(1), id(2)} = l.a;    
end

summary = reshape([summary{:}],size(summary));

end
