% Run the NEAT inverse reinforcement learning algorithm.
function irl_result = neatrun(algorithm_params,mdp_data,mdp_model,...
    feature_data,example_samples,~,verbosity)

% algorithm_params - parameters of the FIRL algorithm:
%       seed (0) - initialization for random seed
%       population_size (5) - population of genomes used
%       max_generations (10) - number of NEAT generations
% mdp_data - definition of the MDP to be solved
% example_samples - cell array containing examples
% irl_result - result of IRL algorithm, generic and algorithm-specific:
%       r - inferred reward function
%       v - inferred value function.
%       q - corresponding q function.
%       p - corresponding policy.
%       opt_acc_itr - cell array containing optimization accuracy at each iteration
%       r_itr - post-optimization reward table at each iteration
%       p_itr - post-optimization policy at each iteration
%       model_itr - post-fitting tree at each iteration
%       model_r_itr - post-fitting reward at each iteration
%       model_p_itr - final policy at each iteration
%       time - total running time
%       mean_opt_time - average optimization time
%       mean_fit_time - average fitting time

% input will be features and samples
%display(feature_data.splittable)
%display(example_samples{1,1})
%output will be state action pairs

% Fill in default parameters.
algorithm_params = neatdefaultparams(algorithm_params);

% Set random seed.
if(algorithm_params.seed >= 0)
	rand('seed',algorithm_params.seed);
end

% Initialize variables.
states = mdp_data.states;
actions = mdp_data.actions;

% Construct mapping from states to example actions.
Eo = zeros(states,1);
for i=1:size(example_samples,1),
    for t=1:size(example_samples,2),
        Eo(example_samples{i,t}(1)) = example_samples{i,t}(2);
    end;
end;

% Run NEAT.
if verbosity ~= 0,
    fprintf(1,'Beginning NEAT\n');
end;
    
[best_policy,total_time_taken] = neat_main(struct('population_size',algorithm_params.population_size,'max_generations',algorithm_params.max_generations,...
	'verbosity',verbosity,...
	'number_input_nodes',size(feature_data.splittable,2),'state_features',feature_data.splittable,'example_state_actions',Eo));

% Build output structure.
irl_result = struct('p',best_policy','time',total_time_taken);
