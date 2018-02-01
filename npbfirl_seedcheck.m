% Convenience script for running a single test.
addpaths;
run('Utilities/cvx/cvx_setup.m');

b = 1;

%{
n = 4;
training_sample_lengths = 1;
training_samples = 4;
%}

n = 16;
training_sample_lengths = 4;
training_samples = 8;


verbosity = 0;

% karan: policy type for npbfirl can be mean or map

%seed_max = 1000;
seed_max = 25;
scores_mean = zeros(1, seed_max);
scores_neat = zeros(1, seed_max);

parfor seed = 1:seed_max

	algorithm_seed = seed;
        seed

	test_result_npbfirl_mean = runtest('npbfirl',struct('policy_type','mean','seed',algorithm_seed),...
					   'linearmdp','gridworld',struct('n',n,'b',b,'seed',algorithm_seed),...
					struct('training_sample_lengths',training_sample_lengths,'training_samples',training_samples,...
						   'verbosity',verbosity,'test_metrics',{{'misprediction'}}));
	score_mean = test_result_npbfirl_mean.metric_scores{2}(2);
	scores_mean(seed) = score_mean;

test_result_npbfirl_neat = runtest('npbfirl',struct('policy_type','neat','seed',algorithm_seed,'max_generations',100,'population_size',100),...
				   'linearmdp','gridworld',struct('n',n,'b',b,'seed',algorithm_seed),...
					  struct('training_sample_lengths',training_sample_lengths,'training_samples',training_samples,...
						 'verbosity',verbosity,'test_metrics',{{'misprediction'}}));
	score_neat = test_result_npbfirl_neat.metric_scores{2}(2);
	scores_neat(seed) = score_neat;
end

clf;
hold on;
plot(scores_mean, '-r')
plot(scores_neat, '-g')

title('Misprediction (Seed Check)');
xlabel('Seed Value');
ylabel('Misprediction Score');
legend('Location','Best');
legend('NPBFIRL (mean)', 'NPBFIRL (neat)');
savefig('npbfirl_seedcheck');

%%
[h1,p1,ci1,stats1] = ttest2(scores_mean, scores_neat);
p1

sum(scores_mean)/seed_max
sum(scores_neat)/seed_max
