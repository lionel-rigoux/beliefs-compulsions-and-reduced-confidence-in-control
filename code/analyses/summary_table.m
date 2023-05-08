function result = summary_table (varargin)

if istable(varargin{1})
    t = varargin{1};
    if nargin > 1
        type = varargin{2};
    end
else
    filePath = varargin{1};
    t = varargin{2};
    if nargin > 2
        type = varargin{3};
    end
end


if ~exist('type','var')
    type = 'std';
end

fprintpval = @(v) printval (v, 'signed', false, 'stars', true);

switch type
    case 'std'
        sst = @(x) sprintf('%0.3f (%0.3f)',nanmean(x), nanstd(x));
    case 'var'
        sst = @(x) sprintf('%0.3f (%0.3f)',nanmean(x), nanvar(x));
    case 'quartile'
        sst = @(x) sprintf('%0.3f [%0.3f, %0.3f]',nanmean(x), quantile(x,.25), quantile(x,.75));
    otherwise
        error('*** summary_table: type must be "std", "var", or "quartile".');
end

avg = groupsummary(t,'hasCompulsion',@(x) string(sst(x)));
avg.Properties.VariableNames = strrep(avg.Properties.VariableNames, 'fun1_','');
avg.GroupCount = [];
avg.hasCompulsion = [];
avg.Properties.RowNames = {'NC';'C'};

p.wilcoxon = varfun(@(x) fprintpval(bootstrap_wilkoxon(x,t.hasCompulsion)), t);
p.ttest = varfun(@(x) fprintpval(bootstrap_ttest2(x,t.hasCompulsion)), t);
p.cohen = varfun(@(x) printval(bootstrap_cohen(x,t.hasCompulsion)), t);
p.sw = varfun(@(x) printsig(bootstrap_shapirowilk(x,t.hasCompulsion)), t);

p.wilcoxon = relabel (p.wilcoxon, 'Wilx');
p.ttest = relabel (p.ttest, 'ttest');
p.cohen = relabel (p.cohen, 'd');
p.sw = relabel (p.sw, 'SW');



result = rows2vars(vertcat(avg, p.cohen, p.ttest, p.sw, p.wilcoxon));
result.Properties.VariableNames{1} = 'Parameter';

if exist('filePath','var')
    writetable(result, filePath, 'QuoteStrings',true);
end

end

function tt = relabel (tt, l)
tt.Properties.VariableNames = strrep(tt.Properties.VariableNames, 'Fun_','');
tt.Properties.VariableNames = strrep(tt.Properties.VariableNames, 'Fun_hasCompulsion','hasCompulsion');
tt.hasCompulsion = [];
tt.Properties.RowNames = {l};
end

function s = printsig (v)
    if v > .05
        s = 'n.s.';
    else
        s = printval (v, 'signed', false, 'digits', 2);
    end
end