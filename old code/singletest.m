% Convenience script for running a single test.
addpaths;
run('Utilities/cvx/cvx_setup.m');

n = 4;
b = 1;
training_sample_lengths = 4;
training_samples = 8;
verbosity = 0;

% karan: policy type for npbfirl can be mean or map
%{
test_result_npbfirl = runtest('neat',struct(),...
				'linearmdp','highway',struct(),...
				struct('training_sample_lengths',training_sample_lengths,'training_samples',training_samples,...
				       'verbosity',verbosity,'test_metrics',{{'misprediction'}}));
%}

%{
test_result_npbfirl = runtest('npbfirl',struct('policy_type','mean'),...
				'linearmdp','highway',struct(),...
				struct('training_sample_lengths',training_sample_lengths,'training_samples',training_samples,...
				       'verbosity',verbosity,'test_metrics',{{'misprediction'}}));
%}

test_result_npbfirl = runtest('npbfirl',struct('policy_type','neat','seed',8),...
			      'linearmdp','gridworld',struct('n',n,'b',b),...
			      struct('training_sample_lengths',training_sample_lengths,'training_samples',training_samples,...
				     'verbosity',verbosity,'test_metrics',{{'misprediction'}}));
%{

test_result_firl = runtest('firl',struct(),...
			     'linearmdp','gridworld',struct('n',n,'b',b),...
			     struct('training_sample_lengths',training_sample_lengths,'training_samples',training_samples,...
				    'verbosity',verbosity,'test_metrics',{{'misprediction'}}));
%}

%{
test_result_neat = runtest('neat',struct('population_size',5,'max_generations',10),...
			     'linearmdp','gridworld',struct('n',n,'b',b),...
			     struct('training_sample_lengths',training_sample_lengths,'training_samples',training_samples,...
				    'verbosity',verbosity,'test_metrics',{{'misprediction'}}));
%}

% Visualize solution.
test_result_npbfirl.metric_scores{1}(1)
test_result_npbfirl.metric_scores{2}(1)

%printresult(test_result_firl);
%printresult(test_result_neat);
%visualize(test_result);
