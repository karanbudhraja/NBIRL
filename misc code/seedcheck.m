% Convenience script for running a single test.
addpaths;
run('Utilities/cvx/cvx_setup.m');

n = 4;
b = 1;
training_sample_lengths = 2;
training_samples = 2;
verbosity = 0;

metric_scrore_1_firl = [];
metric_scrore_2_firl = [];
metric_scrore_1_neat = [];
metric_scrore_2_neat = [];

seeds = [4 19 5 21];

parfor index = 1:length(seeds)

    seed = seeds(index);

    test_result_firl = runtest('firl',struct('seed',seed),...
        'standardmdp','gridworld',struct('seed',seed,'n',n,'b',b),...
        struct('training_sample_lengths',training_sample_lengths,'training_samples',training_samples,...
        'verbosity',verbosity,'test_metrics',{{'misprediction'}}));
    metric_scrore_1_firl = [metric_scrore_1_firl; test_result_firl.metric_scores{1}(1)];
    metric_scrore_2_firl = [metric_scrore_2_firl; test_result_firl.metric_scores{2}(1)];

    %{
    test_result_neat = runtest('neat',struct('seed',seed,'population_size',5,'max_generations',10),...
        'standardmdp','gridworld',struct('seed',seed,'n',n,'b',b),...
        struct('training_sample_lengths',training_sample_lengths,'training_samples',training_samples,...
        'verbosity',verbosity,'test_metrics',{{'misprediction'}}));
    metric_scrore_1_neat = [metric_scrore_1_neat; test_result_neat.metric_scores{1}(1)];
    metric_scrore_2_neat = [metric_scrore_2_neat; test_result_neat.metric_scores{2}(1)];
    %}
end
    
%{
%% Visualize solution.
figure;
hold on;
plot(metric_scrore_1_firl,'-k');
plot(metric_scrore_1_neat,'-*k');
plot(metric_scrore_2_firl,'--k');
plot(metric_scrore_2_neat,'--*k');
title('Compared MDP Misprediction Score');
xlabel('Random Seed');
ylabel('Misprediction Score');
legend('Location','Best');
legend('FIRL','NEAT-IRL');
savefig('comparison');
%}
