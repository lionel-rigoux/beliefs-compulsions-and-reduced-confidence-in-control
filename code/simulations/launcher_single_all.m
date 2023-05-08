function launcher_single_all(allow_no_check)

    paramList = {'prob_successful_wash', 'prob_getting_dirty', 'value_cook_dirty'};
    for i = 1 : numel (paramList)
        launcher_agent_single (paramList{i}, allow_no_check);
    end
end