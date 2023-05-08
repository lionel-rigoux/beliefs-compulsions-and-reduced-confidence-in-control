%% load all external libraries
addpath ../lib/
addpath ../third-party/gramm/
addpath ../third-party/simplex/
addpath ../third-party/pretty-plot/
addpath ../third-party/yaml/
addpath ../third-party/measures-of-effect-size-toolbox/

%% define list of labels for iteration over condition
dataset_list = { ...
    'must_check', ...
    'allow_no_check'
    };

param_list = { ...
    'prob_successful_wash', ...
    'prob_getting_dirty', ...
    'value_cook_dirty' ...
    };

%% load all data

% preprocess results, if not already done. This will go through all the raw
% data, clean them up, and create mat files in the 'scratch' folder with
% all the necessary sufficient statistics for each agent. 
summarize ('must_check')
summarize ('allow_no_check')

% load and store preprocessed data from mat files
summary.must_check = load('scratch/must_check/summary_full.mat');
summary.allow_no_check = load('scratch/allow_no_check/summary_full.mat');
summary.all.summary_full = cat(1,summary.allow_no_check.summary_full,summary.must_check.summary_full);

for iP = 1 : numel (param_list)
    for iD = 1 : 2
        dataFilePath = sprintf('scratch/%s/summary_%s.mat',dataset_list{iD}, param_list{iP});
        summary.(dataset_list{iD}).(param_list{iP}) = load(dataFilePath);
    end
    summary.all.(param_list{iP}).summary = cat(1,summary.must_check.(param_list{iP}).summary, summary.allow_no_check.(param_list{iP}).summary);
end

%% analyse misrepresentation (Delta) of the world for each group
for iD = 1 : numel (dataset_list)
    
    dataset = dataset_list{iD};
    close all;

    % plot fingerprint and get table of all Deltas
    delta = analyse_between_group (summary.(dataset).summary_full);

    % get between group stats
    t_delta = summary_table (delta);

    % add within group stats
    pNC = varfun ( ...
        @(x) printval (bootstrap_ttest (x), 'stars', true), ...
        delta(~ delta.hasCompulsion, 1 : end-1));
    pC = varfun (...
        @(x) printval (bootstrap_ttest (x), 'stars', true), ...
        delta(delta.hasCompulsion, 1 : end-1));
    t_delta.t_NC = string (table2cell (pNC)');
    t_delta.t_C = string (table2cell (pC)');
    t_delta = movevars (t_delta, "t_NC", 'After', "NC");
    t_delta = movevars (t_delta, "t_C", 'After', "C");

    % save table and plot
    writetable (t_delta, ['../../tables/fingerprint_' dataset '.csv'], 'QuoteStrings', true);
    pretty.plot (['../../figures/fingerprint_' dataset '.svg'], [30 12]);

end

%% analyse state transitions
for iD = 1 : numel (dataset_list)
    
    dataset = dataset_list{iD};
    close all;

    % plot state transition graph and get summary statistics
    [t_transitions, h] = analyse_transitions (summary.(dataset).summary_full);
    
    % save plot and table
    summary_table (['../../tables/transition_' dataset '.csv'], t_transitions);
    pretty.plot (['../../figures/trigram_' dataset '.svg'],[40 15])

end

%% analyse effect of cost function on compulsion type
close all
plot_simplex (summary.all.summary_full)
pretty.plot ('../../figures/simplex.svg',[40 10])

t_type = analyse_between_types (summary);
writetable (t_type, '../../tables/compulsion_type.csv', 'QuoteStrings',true);

%% analyse belief density
for iD = 1 : numel (dataset_list)
    
    dataset = dataset_list{iD};
    close all;

    [~, beliefs] = plot_belief_density (summary.(dataset).summary_full);
    summary_table (['../../tables/beliefs_density_' dataset '.csv'], beliefs);
    pretty.plot (['../../figures/belief_density_' dataset '.svg'], [20 10])

end

%% analyse belief update after wash action
for iD = 1 : numel (dataset_list)

    dataset = dataset_list{iD};
    close all;

    [g, t] = plot_update (summary.(dataset).summary_full);
    summary_table (['../../tables/beliefs_update_' dataset '.csv'], t);
    pretty.plot (['../../figures/belief_update_' dataset '.svg'], [10 10]);
end

%% regression on params: fully randomised parameters

% create markdown file to keep track of all results in automated report
fid = fopen ('../../texts/regression_full.md', 'w+');

for iD = 1 : numel (dataset_list)

    dataset = dataset_list{iD};

    % title
    switch dataset
        case 'must_check'
            fprintf (fid, '### Mandatory checking');
        case 'allow_no_check'
            fprintf (fid, '### Relaxing checking constraint');
        case 'all'
            fprintf (fid, '### Both together');
    end

    % for each parameter
    % ------------------
    for iP = 1 : numel (param_list)

        paramName = param_list{iP};
        close all

        % regress symptoms severity on parameter delta
        t = plot_regression (summary.(dataset).summary_full, paramName); 
        
        % save table and plot
        filename = sprintf ('regression_%s_%s', paramName, dataset);
        csvFilePath = sprintf ('tables/%s.csv', filename);
        svgFilePath = sprintf ('figures/%s.svg', filename);
        writetable (t, ['../../' csvFilePath], 'QuoteStrings', true);
        pretty.plot (['../../' svgFilePath], [30 18]);

        % add results to report
        paramLabel = ['$\Delta$' strrep(paramName, '_',' ')];
        fprintf (fid, '\n\n\n');
        fprintf (fid, '#### Regression %s', paramLabel);
        fprintf (fid, '\n\n');
        fprintf (fid, '\n![Effect of %s on compulsion severity.](%s)\n', paramLabel, ['../' svgFilePath]);
        fprintf (fid, '\n{{ #csv %s }}\n', ['../' csvFilePath]);
        fprintf (fid, ': Correlation between compulsivity scores and %s. {#tbl:regression_%s_%s}\n', paramLabel, paramName,dataset);
        fprintf (fid, '\n\n');
        fprintf (fid, '\\newpage');
        
    end
end

% close report
fclose (fid);

%% regression on params: single parameter perturbation

fid = fopen ('../../texts/regression_single.md', 'w+');

for iD = 1 : numel (dataset_list)

    dataset = dataset_list{iD};

    switch dataset
        case 'must_check'
            fprintf (fid, '### Mandatory checking');
        case 'allow_no_check'
            fprintf (fid, '### Relaxing checking constraint');
        case 'all'
            fprintf (fid, '### Both together');
    end

    % for each parameter
    for iP = 1 : numel (param_list)

        paramName = param_list{iP};
        close all

        % regress symptoms severity on parameter delta
        t = plot_regression (summary.(dataset).(paramName).summary, paramName);

        % % save table and plot
        filename = sprintf ('regression_single_%s_%s', paramName, dataset);
        csvFilePath = sprintf ('tables/%s.csv', filename);
        svgFilePath = sprintf ('figures/%s.svg', filename);
        writetable (t, ['../../' csvFilePath], 'QuoteStrings', true);
        pretty.plot (['../../' svgFilePath], [30 18]);

        % add results to report
        paramLabel = ['$\Delta$' strrep(paramName, '_',' ')];
        fprintf (fid, '\n\n\n');
        fprintf (fid, '#### Regression %s',paramLabel);
        fprintf (fid, '\n\n');
        fprintf (fid, '\n![Effect of %s on compulsion severity.](%s)\n', paramLabel, ['../' svgFilePath]);
        fprintf (fid, '\n{{ #csv %s }}\n', ['../' csvFilePath]);
        fprintf (fid, ': Correlation between compulsivity scores and %s. {#tbl:regression_single_%s_%s}\n', paramLabel, paramName, dataset);
        fprintf (fid, '\n\n');
        fprintf (fid, '\\newpage');

    end
end

% close report
fclose(fid);
