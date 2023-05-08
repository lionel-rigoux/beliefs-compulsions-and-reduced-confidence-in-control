function st = analyse_between_types (summary)

% collect compulsive agents
s = summary.all.summary_full(:,2,:);

% put subjective params in a table
p = [s(:).params];
p = [p.subjective];

t = struct2table(p);

% add column with flag if has pure wash but not pure check compulsion
d = [s(:).diagnostic];
% use 'hasCompulsion' as a short for hasPureWash to trick summary_table()
t.hasCompulsion = [d(:).hasWashCompulsion]' & ~[d(:).hasCheckCompulsion]';

% remove undertermined agents
t(~[d.hasWashCompulsion] & ~[d.hasCheckCompulsion],:) = [];

% get summary stats
st = summary_table (t);
st.Properties.VariableNames{2} = 'pure check';
st.Properties.VariableNames{3} = 'pure wash'; 
st(end,:) = [];
