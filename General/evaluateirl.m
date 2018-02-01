% Evaluate result returned by IRL algorithm on given MDP.
function test_result = evaluateirl(algorithm, irl_result,true_r,example_samples,...
    mdp_data,mdp_params,mdp_solution,mdp,~,test_models,test_metrics,...
    feature_data,true_feature_map)

% test_result - data structure encapsulating generic test results:
%   metric_scores - array of results from each metric, for each MDP type
%   irl_result - copy of result from IRL algorithm
%   true_r - true reward function
%   example_samples - copy of example samples
%   mdp_data - copy of MDP data
%   mdp_params - copy of MDP parameters
%   mdp_solution - copy of true MDP solution
%   feature_data - copy of feature data
%   mdp - type of MDP used

metric_scores = cell(length(test_models),length(test_metrics));
for m=1:length(test_models),
    % Evaluate for each test model.
    cur_model = test_models{m};
    mdp_solve = str2func(strcat(cur_model,'solve'));
    
    % karan adding exception code for NEAT
    if(strcmp(algorithm, 'neat') == 1)
        irl_soln = irl_result;
        irl_r = 0;
    elseif(strcmp(algorithm, 'npbfirl') == 1)
        irl_soln = irl_result;
        irl_r = 0;
    else
        irl_soln = mdp_solve(mdp_data,irl_result.r);
        irl_r = irl_result.r;
    end
    
    mdp_soln = mdp_solve(mdp_data,true_r);
    
    
    % Evaluate each metric.
    for k=1:length(test_metrics),
        cur_metric = test_metrics{k};
        metric_scores{m,k} = feval(strcat(cur_metric,'score'),mdp_soln,...
            true_r,irl_soln,irl_r,feature_data,true_feature_map,...
            mdp_data,mdp_params,cur_model);
    end;
end;

% Build results structure.
test_result = struct(...
    'metric_scores',{metric_scores},...
    'irl_result',irl_result,...
    'true_r',true_r,...
    'example_samples',{example_samples},...
    'test_models',{test_models},...
    'test_metrics',{test_metrics},...
    'mdp_data',mdp_data,...
    'mdp_params',feval(strcat(mdp,'defaultparams'),mdp_params),...
    'mdp_solution',mdp_solution,...
    'feature_data',feature_data,...
    'mdp',mdp,...
    'time',irl_result.time);
