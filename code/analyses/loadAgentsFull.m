function summary = loadAgentsFull (prefix)

fprintf('Summarizing full simulations (%s)...\n', prefix);

% find all files corresponding to the contxt
resultDir = sprintf('../../results/%s/', prefix);

d = dir ([resultDir 'full_*']);
for i = 1 : numel (d)
    fprintf('%0.3f %%\n',100*i/numel(d))
    % load result file
    [id,n] = sscanf (d(i).name, 'full_%d_%d_%d.mat');
    
    if n > 1
    l = load ([resultDir d(i).name]);
    l.a.simulation = [];
    l.a.log = [];

    % organize
    summary{id(1),id(2)+1,id(3)} = l.a;    
    end
end

summary = reshape([summary{:}],size(summary));

end
