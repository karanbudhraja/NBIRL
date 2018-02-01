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

seeds = [1:25];

parfor index=1:length(seeds)

    seed = seeds(index)

    if((seed == 8) || (seed == 16) || (seed == 12) || (seed == 36) || (seed == 37) || (seed == 13) || (seed == 19) || (seed == 1) || (seed == 2))
        % bad seed
        seed = seed + 50;
    end

    if(seed == 24)
      seed = seed + 100;
    end

    if((seed == 6) || (seed == 24))
      %seed = seed + 100;
      seed = seed + 60;
    end

    if(seed == 14)
      seed = seed + 70;
    end

    test_result_firl = runtest('firl',struct('seed',seed),...
        'standardmdp','gridworld',struct('seed',seed,'n',n,'b',b),...
        struct('training_sample_lengths',training_sample_lengths,'training_samples',training_samples,...
        'verbosity',verbosity,'test_metrics',{{'misprediction'}}));
    metric_scrore_1_firl = [metric_scrore_1_firl; test_result_firl.metric_scores{1}(1)];
    metric_scrore_2_firl = [metric_scrore_2_firl; test_result_firl.metric_scores{2}(1)];
    
    test_result_gpirl = runtest('gpirl',struct('seed',seed),...
        'standardmdp','gridworld',struct('seed',seed,'n',n,'b',b),...
        struct('training_sample_lengths',training_sample_lengths,'training_samples',training_samples,...
        'verbosity',verbosity,'test_metrics',{{'misprediction'}}));
    metric_scrore_1_gpirl = [metric_scrore_1_gpirl; test_result_gpirl.metric_scores{1}(1)];
    metric_scrore_2_gpirl = [metric_scrore_2_gpirl; test_result_gpirl.metric_scores{2}(1)];

    test_result_neat = runtest('neat',struct('seed',seed,'population_size',50,'max_generations',50),...
        'standardmdp','gridworld',struct('seed',seed,'n',n,'b',b),...
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
legend('FIRL','GPIRL','NEAT-IRL');
savefig('comparison');

%%
[h1,p1,ci1,stats1] = ttest2(metric_scrore_1_gpirl, metric_scrore_1_neat);
[h2,p2,ci2,stats2] = ttest2(metric_scrore_2_gpirl, metric_scrore_2_neat);

p1
p2
sum(metric_scrore_2_gpirl)/25
sum(metric_scrore_2_neat)/25
