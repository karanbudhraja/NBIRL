% Compare NEAT and FIRL.
addpaths;
run('Utilities/cvx/cvx_setup.m');

% taking standard arguments from toolkit test
b = 1;

%{
max_sample_length = 8;
training_sample_lengths = 1:max_sample_length;
grid_size = 8;
training_samples = 8;
%}

%% testing on a standard grid proportion: 32(n):16(samples):8(length)
max_sample_length = 2;
training_sample_lengths = 1:max_sample_length;
grid_size = 16;
training_samples = 8;

verbosity = 0;

algorithm_seed = -1; % no seed
max_generations = 2;
population_size = 2;

iterations = 1;
firl_total_standard_mdp_scores = zeros(1,length(training_sample_lengths));
firl_total_linear_mdp_scores = zeros(1,length(training_sample_lengths));
gpirl_total_standard_mdp_scores = zeros(1,length(training_sample_lengths));
gpirl_total_linear_mdp_scores = zeros(1,length(training_sample_lengths));
neat_total_standard_mdp_scores = zeros(1,length(training_sample_lengths));
neat_total_linear_mdp_scores = zeros(1,length(training_sample_lengths));
firl_total_times = zeros(1,length(training_sample_lengths));
girl_total_times = zeros(1,length(training_sample_lengths));
neat_total_times = zeros(1,length(training_sample_lengths));

for iteration = 1:iterations
    
    iteration
    algorithm_seed = iteration;
    
    if(algorithm_seed >= 22)
        % bad seed
        algorithm_seed = algorithm_seed + 4;
    end

    standard_mdp_scores = [];
    linear_mdp_scores = [];
	current_times = [];

    for index = 1:length(training_sample_lengths)
        training_sample_length = training_sample_lengths(index);
		test_result_firl = runtest('firl',struct('seed',algorithm_seed),...
			'standardmdp','gridworld',struct('seed',algorithm_seed,'n',grid_size,'b',b),...
			struct('training_sample_lengths',training_sample_length,'training_samples',training_samples,...
			'verbosity',verbosity,'test_metrics',{{'misprediction'}}));

        standard_mdp_score = test_result_firl.metric_scores{1}(1);
        linear_mdp_score = test_result_firl.metric_scores{2}(1);

        standard_mdp_scores = [standard_mdp_scores; standard_mdp_score];
        linear_mdp_scores = [linear_mdp_scores; linear_mdp_score];
		current_times = [current_times; test_result_firl.time];
    end
    
    firl_total_standard_mdp_scores = firl_total_standard_mdp_scores + standard_mdp_scores';
    firl_total_linear_mdp_scores = firl_total_linear_mdp_scores + linear_mdp_scores';
    firl_total_times = firl_total_times + current_times';

    standard_mdp_scores = [];
    linear_mdp_scores = [];
	current_times = [];

    for index = 1:length(training_sample_lengths)
        training_sample_length = training_sample_lengths(index);
		test_result_firl = runtest('gpirl',struct('seed',algorithm_seed),...
			'standardmdp','gridworld',struct('seed',algorithm_seed,'n',grid_size,'b',b),...
			struct('training_sample_lengths',training_sample_length,'training_samples',training_samples,...
			'verbosity',verbosity,'test_metrics',{{'misprediction'}}));

        standard_mdp_score = test_result_firl.metric_scores{1}(1);
        linear_mdp_score = test_result_firl.metric_scores{2}(1);

        standard_mdp_scores = [standard_mdp_scores; standard_mdp_score];
        linear_mdp_scores = [linear_mdp_scores; linear_mdp_score];
		current_times = [current_times; test_result_firl.time];
    end
    
    gpirl_total_standard_mdp_scores = gpirl_total_standard_mdp_scores + standard_mdp_scores';
    gpirl_total_linear_mdp_scores = gpirl_total_linear_mdp_scores + linear_mdp_scores';
    gpirl_total_times = gpirl_total_times + current_times';

    standard_mdp_scores = [];
    linear_mdp_scores = [];
	current_times = [];

    for index = 1:length(training_sample_lengths)
        training_sample_length = training_sample_lengths(index);
		test_result_neat = runtest('neat',struct('seed',algorithm_seed,'population_size',population_size,'max_generations',max_generations),...
            'standardmdp','gridworld',struct('seed',algorithm_seed,'n',grid_size,'b',b),...
            struct('training_sample_lengths',training_sample_length,'training_samples',training_samples,...
            'verbosity',verbosity,'test_metrics',{{'misprediction'}}));

        standard_mdp_score = test_result_neat.metric_scores{1}(1);
        linear_mdp_score = test_result_neat.metric_scores{2}(1);

        standard_mdp_scores = [standard_mdp_scores; standard_mdp_score];
        linear_mdp_scores = [linear_mdp_scores; linear_mdp_score];
		current_times = [current_times; test_result_neat.time];
    end
    
    neat_total_standard_mdp_scores = neat_total_standard_mdp_scores + standard_mdp_scores';
    neat_total_linear_mdp_scores = neat_total_linear_mdp_scores + linear_mdp_scores'; 
    neat_total_times = neat_total_times + current_times';    
end

firl_average_standard_mdp_scores = firl_total_standard_mdp_scores/iterations;
firl_average_linear_mdp_scores = firl_total_linear_mdp_scores/iterations;
gpirl_average_standard_mdp_scores = firl_total_standard_mdp_scores/iterations;
gpirl_average_linear_mdp_scores = firl_total_linear_mdp_scores/iterations;
neat_average_standard_mdp_scores = neat_total_standard_mdp_scores/iterations;
neat_average_linear_mdp_scores = neat_total_linear_mdp_scores/iterations;
firl_average_times = firl_total_times/iterations;
gpirl_average_times = firl_total_times/iterations;
neat_average_times = neat_total_times/iterations;

figure;
hold on;
plot(training_sample_lengths, firl_average_standard_mdp_scores,'-sk');
plot(training_sample_lengths, gpirl_average_standard_mdp_scores,'-^k');
plot(training_sample_lengths, neat_average_standard_mdp_scores,'-*k');
plot(training_sample_lengths, firl_average_linear_mdp_scores,'--sk');
plot(training_sample_lengths, gpirl_average_linear_mdp_scores,'--^k');
plot(training_sample_lengths, neat_average_linear_mdp_scores,'--*k');
title('Compared MDP Misprediction Score');
xlabel('Number of Training Samples');
ylabel('Misprediction Score');
legend('Location','Best');
legend('FIRL','GPIRL','NEAT-IRL');
savefig('misprediction_score');

figure;
hold on;
plot(training_sample_lengths, firl_average_times,'-sk');
plot(training_sample_lengths, gpirl_average_times,'-^k');
plot(training_sample_lengths, neat_average_times,'-*k');
title('Execution Time');
xlabel('Number of Training Samples');
ylabel('Execution Time');
legend('Location','Best');
legend('FIRL','GPIRL','NEAT-IRL');
savefig('execution time')
