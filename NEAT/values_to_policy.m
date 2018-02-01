% Convert state values to a policy.
function policy = values_to_policy(output)

min_value = -inf;
n = sqrt(size(output,1));
policy = zeros(1,n^2);

for y=1:n,
    for x=1:n,
        % Compute term index.
		index = (y-1)*n + x;
		
		% Compute neighbor values
		index_up = (y-1)*n + (x-1);
		index_down = (y-1)*n + (x+1);
		index_right = (y)*n + x;
		index_left = (y-2)*n + x;

		best_value = min_value;
		best_action = 1;	% default action is to stay

		% selection is random in case of a tie

		if(index_up >= 1) && (index_up <= n^2)
			if((output(index_up) > best_value) || ((output(index_up) == best_value) && (rand() > 0.5)))	
				best_value = output(index_up);
				best_action = 5;
			end		
		end

		if(index_down >= 1) && (index_down <= n^2)
			if((output(index_down) > best_value) || ((output(index_down) == best_value) && (rand() > 0.5)))
				best_value = output(index_down);
				best_action = 3;
			end		
		end

		if(index_right >= 1) && (index_right <= n^2)
			if((output(index_right) > best_value) || ((output(index_right) == best_value) && (rand() > 0.5)))
				best_value = output(index_right);
				best_action = 2;
			end		
		end

		if(index_left >= 1) && (index_left <= n^2)
			if((output(index_left) > best_value) || ((output(index_left) == best_value) && (rand() > 0.5)))
				best_value = output(index_left);
				best_action = 4;
			end		
		end

        policy(index) = best_action;
    end;
end;

