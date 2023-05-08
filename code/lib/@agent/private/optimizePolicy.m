function obj = optimizePolicy (obj)

if isempty (obj.params.subjective)
    mode = 'world';
else
    mode = 'subjective';
end

params = obj.params.(mode);


%% ========================================================================
%  SOLVING THE POMDP
%  ========================================================================

% store model description in a tempfile
warning off

filenameBase = tempname('.');
filenameAbs = fullfile (tempdir, filenameBase);

filename.POMDP_rel = [filenameBase '.POMDP'];
filename.POMDP = [filenameAbs '.POMDP'];
filename.solution_rel = [filenameBase '_solution'];
filename.solution = [filenameAbs '_solution'];
filename.alpha = [filename.solution '.alpha'];
filename.pg = [filename.solution '.pg'];

cleanup = onCleanup(@() delete_temp(filename));


%% ------------------------------------------------------------------------
%   Calling the pomdp-solve routine
%% ------------------------------------------------------------------------

%fprintf('Solving the pomdp...');



% write the specification in a text file
writePOMDP (params, 'file', filename.POMDP);

% call the solver
relPath = fileparts (mfilename ('fullpath'));
if ismac()
    binName = 'pomdp-solve-mac';
elseif isunix()
    binName = 'pomdp-solve-unix';
else
    error('platform not supported');
end

[status, cmdout] = system (sprintf ('cd %s; %s/%s -pomdp "%s" -o "%s" -stop_criteria ''bellman'' -time_limit 300 -stop_delta 1e-1 -witness_points true', tempdir, relPath, binName, filename.POMDP_rel, filename.solution_rel));

%todo check status
if status ~= 0
    error (cmdout);
end

%% ------------------------------------------------------------------------
%   Loading results 
%% ------------------------------------------------------------------------

% load the results
pomdp = readPOMDP (filename.POMDP) ;

%% ------------------------------------------------------------------------
%   Loading the alpha vectors
%% ------------------------------------------------------------------------

fid.alpha = fopen (filename.alpha);
% => see http://pomdp.org/code/alpha-file-spec.html

A = fscanf (fid.alpha, '%d%f%f') ;
A = reshape (A, 3, numel (A) / 3);

alpha_action = A(1, :) + 1;
alpha_vector = A(2:3, :);

% %% ------------------------------------------------------------------------
% %   Computing the value function
% %% ------------------------------------------------------------------------
% 
% % for display purpose, we will evaluate the value of each action over the
% % full continuous belief space
% 
% belief_subsampling = 1e3;
% belief_space = linspace (0, 1, belief_subsampling); % 0: clean, 1:dirty, according to the pomdp
% 
% % compute value function for each alpha vector
% V_alpha = nan (numel (alpha_action), belief_subsampling);
% for i = 1 : belief_subsampling
%     V_alpha(:, i) = [1 - belief_space(i),  belief_space(i)] * alpha_vector ;
% end
% 
% % collapse vectors associated with the same same action
% V = nan (pomdp.nrActions, belief_subsampling);
% for iAction = 1 : pomdp.nrActions
%     act_idx = find (alpha_action == iAction);
%     if ~ isempty (act_idx)
%         V (iAction, :) = max (V_alpha(act_idx, :), [], 1);
%     end
% end
% 
% % => V is the value of each action (lines) as a function of belief (columns)
% 
% %% ------------------------------------------------------------------------
% %   Computing belief partition
% %% ------------------------------------------------------------------------
% 
%
% %% ------------------------------------------------------------------------
% %   Loading the belief MDP policy
% %% ------------------------------------------------------------------------
% 
% fid.pg = fopen (filename.pg);
% 
% % => see http://pomdp.org/code/pg-file-spec.html
% ss = fread (fid.pg, '*char')';
% ss = strrep (ss, '-', 'NaN');
% 
% P = round (sscanf (ss, '%f')) ;
% P = reshape (P, 2 + pomdp.nrObservations, numel (P) / (2 + pomdp.nrObservations));
% 
% bmdp.nrStates = size (P, 2);
% 
% for iS = 1 : bmdp.nrStates
%     for iO = 1 : pomdp.nrObservations
%         if ~ isnan (P(2 + iO, iS))
%         bmdp.transition(P(2 + iO, iS) + 1, iS, iO) = 1;
%         end
%     end
% end
% 
% bmdp.policy = P(2, :) + 1;
% 
% policy_belief = zeros (size (V_alpha, 1), belief_subsampling);
% for i = 1 : belief_subsampling
%     bestS = find (V_alpha(:, i) == max (V_alpha(:, i)), 1);
%     policy_belief(bestS, i) = bmdp.policy (bestS);
% end


% => S is the optimal policy for each substate as a function of belief (columns)


%% ========================================================================
%  SAVING EVERYTHING
%  ========================================================================

obj.log.(mode).date           = datetime ;
obj.log.(mode).config         = params ;
obj.log.(mode).optimization   = cmdout ;

obj.pomdp.(mode) = pomdp;
%obj.policy  = pomdp ;
%results.bmdp   = bmdp ;

obj.policy.action = alpha_action;
obj.policy.value  = alpha_vector;

%results.plot.belief_space  = belief_space ;
%results.plot.alpha_values  = V_alpha ;
%results.plot.policy_belief = policy_belief;
%results.plot.action_values = V ;



% cleanup



end

function delete_temp(filename)
    if exist(filename.POMDP,'file')
        delete(filename.POMDP);
    end
    if exist(filename.pg, 'file')
        delete(filename.pg);
    end
    if exist(filename.alpha, 'file')
        delete(filename.alpha);
    end
    if exist(filename.solution, 'file')
        delete(filename.solution);
    end
end



