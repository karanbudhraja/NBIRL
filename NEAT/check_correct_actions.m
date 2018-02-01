% Check number of actions that matched example policy.
function correct_actions = check_correct_actions(output, example_state_actions)

n = sqrt(size(output,1));

% convert output to a policy
policy = values_to_policy(output);

correct_actions = 0;

% compare non zero example_state_actions
for index = 1:n^2
	if(example_state_actions(index) == 0)
		correct_actions = correct_actions + 1;	
	elseif(example_state_actions(index) == policy(index))
		correct_actions = correct_actions + 1;
	elseif((example_state_actions(index) == 'l') && (policy(index) == 'r'))
		correct_actions = correct_actions - 1;
	elseif((example_state_actions(index) == 'r') && (policy(index) == 'l'))
		correct_actions = correct_actions - 1;
	elseif((example_state_actions(index) == 'u') && (policy(index) == 'd'))
		correct_actions = correct_actions - 1;
	elseif((example_state_actions(index) == 'd') && (policy(index) == 'u'))
		correct_actions = correct_actions - 1;
	end
end

