addpath ../lib
addpath ../third-party/yaml

%% generate valid worlds
launcher_world ()

%% generate agents with fully randomized subjective parameters
% A: All action required
launcher_agent(false) 
% B: allow for non-checking agents
launcher_agent(true)

%% generate agents with partial parameter perturbations
% A: All action required
launcher_single_all(false);
% B: allow for non-checking agents
launcher_single_all(true);
