%% Setup
% % =======================================================================
% add agent class
addpath ("lib")
% for plotting functions
addpath ("analyses")

%% Create world
% % =======================================================================
% % First, we look for a set of (world) parameters for which the optimal
% % policy does not include any repetition of check and/or wash actions. In
% % practice, this amounts to creating a new agent object: upon
% % initialisation this object will pick random parameters to define the 
% % POMDP problem, and compute the optimal policy. At this point, the 
% % subjective and world parameters are equal, i.e. the agent has a true 
% % representation of the world and can serve as a benchmark.
% 
% % As random parametrisation can yield invalid policies, we generate
% % agents until we find one with an acceptable "control" behaviour.
%
% OK = false;
% while ~ OK
%    % create a new agent with random parameters
%    a = agent ();
%    % simulate 5 sequences of 1000 actions
%    a.simulate (5, 1000);
%    % quantify behavioural markers
%    a.diagnose ();
%    % if no compulsions and complete policy, stop searching
%    OK = ~ a.diagnostic.hasCompulsion && a.diagnostic.doCheck;
% end

% % for the sake of speed, let's pick a set of parameters we know are
% % working:

params = struct ( ...
    "discount", 0.9, ...
    "prob_getting_dirty", 0.03, ...
    "prob_successful_wash", 0.95, ...
    "prob_detect_clean", 0.85, ...
    "prob_detect_dirty", 0.85, ...
    "value_wash", -0.21, ...
    "value_check", -0.14, ...
    "value_cook_dirty", -0.65, ...
    "value_cook_clean", 0 ...
    );

% create a new world/agent 
a = agent (params);

%% Check world
% % =======================================================================
% % Here, we just check what would be the behaviour of an truely optimal
% % agent whose subjective parameters are equal to the true world
% % parameters

% simulate 5 sequences of 1000 actions
a.simulate (5,1000);

% get statistics of behavioural sequences
a.diagnose ()

% show results
plot_agent (a)
set (gcf, 'Name', 'objectivily optimal')

%% Effect of parameter deviations
% % =======================================================================
% % We now generate an agent with subjective parameters which differs from 
% % the true ones directing the world evolution. For a complete, random 
% % perturbation, use:
%
% a.changeSubjective ()
%
% % Here, we will focus on the parameter of interest and define the value
% % manually to create a subjective belief about the worlds which solely 
% % underestimate the probabilitiy of washing sucess.

% change subjective parameter, implicitely recomputing the (subjectively)
% optimal policy
a.changeSubjective ( ...
    "prob_successful_wash", ...
    0.60 * a.params.world.prob_successful_wash ...
    );

% display difference between subjective and world parameters
a.getDelta ()

% simulate 5 sequences of 1000 actions
a.simulate (5, 1000);

% get statistics of behavioural sequences
a.diagnose ()

% show results
plot_agent (a)
set (gcf, 'Name', 'wash success underestimation')

