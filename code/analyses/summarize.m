function summarize(prefix)

    targetName = sprintf('scratch/%s/summary_full', prefix);
    if ~isfile([targetName '.mat'])
        [~,~] = mkdir(sprintf('scratch/%s', prefix));
        summary_full = loadAgentsFull (prefix);
        save(targetName, 'summary_full')
    end

    paramList = {'prob_successful_wash','prob_detect_clean','prob_detect_dirty','value_cook_dirty','discount','prob_getting_dirty','value_wash','value_check'};
    for i = 1 : numel (paramList)
        paramName = paramList{i};
        targetName = sprintf('scratch/%s/summary_%s', prefix, paramName);
        if ~isfile([targetName '.mat'])
            summary = loadAgentsSpecific (paramName, prefix);
            save(targetName, 'summary')
        end
    end