%%%%%%%%%%%%%%%% XOR experiment file  (contains experiment, receives genom, decodes it, evaluates it and returns raw fitnesses) (function)

%% Neuro_Evolution_of_Augmenting_Topologies - NEAT 
%% developed by Kenneth Stanley (kstanley@cs.utexas.edu) & Risto Miikkulainen (risto@cs.utexas.edu)
%% Coding by Christian Mayr (matlab_neat@web.de)

function [population_plus_fitnesses, best_fitness, best_output]=gridworld_experiment(population, number_input_nodes, state_features, example_state_actions);
population_plus_fitnesses=population;
no_change_threshold=1e-3; %threshold to judge if state of a node has changed significantly since last iteration
number_individuals=size(population,2);

% karan tracking best fitness and best output
best_fitness = -inf;
best_output = -inf;

%{
input_pattern=[0 0;
               0 1; 
               1 0;
               1 1];

output_pattern=[0;
                0.5;
                0.5;
                1];
%}
input_pattern = state_features;	% now an argument
             
for index_individual=1:number_individuals   
   number_nodes=size(population(index_individual).nodegenes,2);
   number_connections=size(population(index_individual).connectiongenes,2);
   individual_fitness=0;
   output=[];
   for index_pattern=1:size(input_pattern,1)
      % the following code assumes node 1 and 2 inputs, node 3 bias, node 4 output, rest arbitrary (if existent, will be hidden nodes)
	  % karan generalizing to any number_input_nodes
      % set node input steps for first timestep
      population(index_individual).nodegenes(3,number_input_nodes+2:number_nodes)=0; %set all node input states to zero
      population(index_individual).nodegenes(3,number_input_nodes+1)=1; %bias node input state set to 1
      population(index_individual).nodegenes(3,1:number_input_nodes)=input_pattern(index_pattern,:); %node input states of the two input nodes are consecutively set to the XOR input pattern  
      
      %set node output states for first timestep (depending on input states)
      population(index_individual).nodegenes(4,1:number_input_nodes+1)=population(index_individual).nodegenes(3,1:number_input_nodes+1);
      population(index_individual).nodegenes(4,number_input_nodes+2:number_nodes)=1./(1+exp(-4.9*population(index_individual).nodegenes(3,number_input_nodes+2:number_nodes)));
      no_change_count=0;     
      index_loop=0;

	  %%%%%%%%%%%%%%%%%%%%%%% KARAN CHECK THIS 3 HERE MAYBE IT IS (2 + 1)=INPUTS
      while (no_change_count<number_nodes) & index_loop<(number_input_nodes+1)*number_connections
         index_loop=index_loop+1;
         vector_node_state=population(index_individual).nodegenes(4,:);
         for index_connections=1:number_connections
            %read relevant contents of connection gene (ID of Node where connection starts, ID of Node where it ends, and connection weight)
            ID_connection_from_node=population(index_individual).connectiongenes(2,index_connections);
            ID_connection_to_node=population(index_individual).connectiongenes(3,index_connections);
            connection_weight=population(index_individual).connectiongenes(4,index_connections);
            %map node ID's (as extracted from single connection genes above) to index of corresponding node in node genes matrix
            index_connection_from_node=find((population(index_individual).nodegenes(1,:)==ID_connection_from_node));
            index_connection_to_node=find((population(index_individual).nodegenes(1,:)==ID_connection_to_node));
                        
            if population(index_individual).connectiongenes(5,index_connections)==1 %Check if Connection is enabled
               population(index_individual).nodegenes(3,index_connection_to_node)=population(index_individual).nodegenes(3,index_connection_to_node)+population(index_individual).nodegenes(4,index_connection_from_node)*connection_weight; %take output state of connection_from node, multiply with weight, add to input state of connection_to node
            end
         end
         %pass on node input states to outputs for next timestep 
         population(index_individual).nodegenes(4,number_input_nodes+2:number_nodes)=1./(1+exp(-4.9*population(index_individual).nodegenes(3,number_input_nodes+2:number_nodes)));          
         %Re-initialize node input states for next timestep
         population(index_individual).nodegenes(3,number_input_nodes+2:number_nodes)=0; %set all output and hidden node input states to zero
         no_change_count=sum(abs(population(index_individual).nodegenes(4,:)-vector_node_state)<no_change_threshold); %check for alle nodes where the node output state has changed by less than no_change_threshold since last iteration through all the connection genes
      end
      
      output=[output;population(index_individual).nodegenes(4,number_input_nodes+2)];

      % karan commenting beacuse its not being used
      %individual_fitness=individual_fitness+abs(output_pattern(index_pattern,1)-population(index_individual).nodegenes(4,4)); %prevent oscillatory connections from achieving high fitness

      if index_loop>=2.7*number_connections
         index_individual
         %population(index_individual).connectiongenes
      end

   end

   % karan printing output
   %output
   % KARAN: IF PERFORMANCE IS BAD, CHECK IF ASSUMED DIRECTIONS NEED TO BE CHANGED 
   correct_actions = check_correct_actions(output, example_state_actions);

   %{
   correct_actions = 0;
   if(output(1) < output(2))
     correct_actions = correct_actions + 1;
   end
   if(output(1) < output(3))
     correct_actions = correct_actions + 1;
   end
   if(output(2) < output(4))
     correct_actions = correct_actions + 1;
   end
   if(output(3) < output(4))
     correct_actions = correct_actions + 1;
   end
   %}

   %Fitness function as defined by karan
   population_plus_fitnesses(index_individual).fitness=correct_actions;    
   
   if(population_plus_fitnesses(index_individual).fitness > best_fitness)
      best_fitness = population_plus_fitnesses(index_individual).fitness;
      best_output = output;
   end

   %Fitness function as defined by Kenneth Stanley
   %{
   population_plus_fitnesses(index_individual).fitness=(4-individual_fitness)^2;    
   if sum(abs(round(output)-output_pattern))==0      
      population_plus_fitnesses(index_individual).fitness=16;
      output
   end
   %}
end 
