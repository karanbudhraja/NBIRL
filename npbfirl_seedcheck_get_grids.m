% Convenience script for running a single test.
addpaths;
run('Utilities/cvx/cvx_setup.m');

b = 1;

n = 4;
training_sample_lengths = 1;
training_samples = 4;

%{
n = 16;
training_sample_lengths = 4;
training_samples = 8;
%}

verbosity = 0;

% karan: policy type for npbfirl can be mean or map

%seeds = [7,15,24,25];
seeds = 1:25;


for seed_index = 1:length(seeds)
	algorithm_seed = seeds(seed_index);
        algorithm_seed

	if(algorithm_seed >= 22)
	  % bad seed
	  algorithm_seed = algorithm_seed + 4;
	end

	if( (algorithm_seed == 8) || (algorithm_seed == 16) || (algorithm_seed == 12) || (algorithm_seed == 5) || (algorithm_seed == 2) || (algorithm_seed == 10) || (algorithm_seed == 14) ) 
	% bad seed
	algorithm_seed = algorithm_seed + 30;
	end



	mdp = 'gridworld';
        mdp_model = 'linearmdp';
        mdp_params = struct('n',n,'b',b,'seed',algorithm_seed);

	% Construct MDP and features.
	[mdp_data,r,feature_data,true_feature_map] = feval(strcat(mdp,'build'),mdp_params);
        % Solve example.
        size(r)     

end
