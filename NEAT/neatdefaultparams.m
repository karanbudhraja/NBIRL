% Fill in default parameters for the FIRL algorithm.
function algorithm_params = firldefaultparams(algorithm_params)

% Create default parameters.
default_params = struct(...
    'seed',0,...
    'population_size',150,...
    'max_generations',200);

% Set parameters.
algorithm_params = filldefaultparams(algorithm_params,default_params);
