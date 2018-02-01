% Convenience script for running a single test.
addpaths;
run('Utilities/cvx/cvx_setup.m');

n = 4;
b = 1;
training_sample_lengths = 1;
training_samples = 2;
verbosity = 0;

metric_scrore_1_firl = [];
metric_scrore_2_firl = [];
metric_scrore_1_gpirl = [];
metric_scrore_2_gpirl = [];
metric_scrore_1_neat = [];
metric_scrore_2_neat = [];

seeds = [1:50];

parfor index = 1:length(seeds)

    seed = seeds(index);

    test_result_firl = runtest('firl',struct('seed',seed),...
        'linearmdp','gridworld',struct('seed',seed,'n',n,'b',b),...
        struct('training_sample_lengths',training_sample_lengths,'training_samples',training_samples,...
        'verbosity',verbosity,'test_metrics',{{'misprediction'}}));
    metric_scrore_1_firl = [metric_scrore_1_firl; test_result_firl.metric_scores{1}(1)];
    metric_scrore_2_firl = [metric_scrore_2_firl; test_result_firl.metric_scores{2}(1)];
 
    test_result_firl = runtest('gpirl',struct('seed',seed),...
        'linearmdp','gridworld',struct('seed',seed,'n',n,'b',b),...
        struct('training_sample_lengths',training_sample_lengths,'training_samples',training_samples,...
        'verbosity',verbosity,'test_metrics',{{'misprediction'}}));
    metric_scrore_1_gpirl = [metric_scrore_1_gpirl; test_result_gpirl.metric_scores{1}(1)];
    metric_scrore_2_gpirl = [metric_scrore_2_gpirl; test_result_gpirl.metric_scores{2}(1)];

    test_result_neat = runtest('neat',struct('seed',seed,'population_size',50,'max_generations',50),...
        'linearmdp','gridworld',struct('seed',seed,'n',n,'b',b),...
        struct('training_sample_lengths',training_sample_lengths,'training_samples',training_samples,...
        'verbosity',verbosity,'test_metrics',{{'misprediction'}}));
    metric_scrore_1_neat = [metric_scrore_1_neat; test_result_neat.metric_scores{1}(1)];
    metric_scrore_2_neat = [metric_scrore_2_neat; test_result_neat.metric_scores{2}(1)];
end
    
%% Visualize solution.
figure;
hold on;
plot(seeds, metric_scrore_1_firl,'-sk');
plot(seeds, metric_scrore_1_gpirl,'-^k');
plot(seeds, metric_scrore_1_neat,'-*k');
plot(seeds, metric_scrore_2_firl,'--sk');
plot(seeds, metric_scrore_2_gpirl,'--^k');
plot(seeds, metric_scrore_2_neat,'--*k');
title('Compared MDP Misprediction Score');
xlabel('Random Seed');
ylabel('Misprediction Score');
legend('Location','Best');
legend('FIRL','NEAT-IRL');
savefig('comparison');

[h1,p1,ci1,stats1] = ttest(metric_scrore_1_firl, metric_scrore_1_neat)
[h2,p2,ci2,stats2] = ttest(metric_scrore_2_firl, metric_scrore_2_neat)
