% Decentralized_Qlearning_Resource_Allocation_in_WNs

%   Francesc Wilhelmi, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Boris Bellalta, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Cristina Cano, Wireless Networks Research Group (WINE-UOC), Universitat Oberta de Catalunya (UOC)
%   Anders Jonsson, Artificial Intelligence and Machine Learning Research Group (AIML-UPF), Universitat Pompeu Fabra (UPF)

function [tpt_experienced_by_WLAN, Qval] = QlearningMethod(wlan, ...
    MAX_CONVERGENCE_TIME, MAX_LEARNING_ITERATIONS, gamma, initial_epsilon, ...
    alpha, updateMode, actions_ch, actions_cca, actions_tpc, noise, printInfo)

% QlearningMethod - Given an OBSS, applies QLearning to maximize the
% experienced throughput
%   OUTPUT: 
%       * tpt_experienced_by_WLAN - throughput experienced by each WLAN
%         for each of the iterations done
%   INPUT: 
%       * wlan - wlan object containing information about all the WLANs
%       * MAX_CONVERGENCE_TIME - maximum number of iterations
%       * MAX_LEARNING_ITERATIONS - maximum number of iterations that an
%       agent performs at the same time
%       * gamma - discount factor (Q-learning)
%       * initial_epsilon - exploration coefficient (Q-learning)
%       * alpha - learning rate (Q-learning)
%       * actions_ch - set of channels
%       * actions_cca - set of carrier sense thresholds
%       * actions_tpc - set of transmit power values
%       * noise - floor noise in dBm
%       * printInfo - to print information at the end of the simulation

    % Use a copy of wlan to make operations
    wlan_aux = wlan;

    n_WLANs = size(wlan,2);
    % Each state represents an [i,j,k] combination for indexes on "channels", "CCA" and "TxPower"
    possible_actions = 1:(size(actions_ch,2)*size(actions_cca,2)*size(actions_tpc,2));
    % Total number of actions
    K = size(possible_actions,2);
    
    % Find the index of the initial action taken by each WLAN
    initial_action_ix_per_wlan = zeros(1, n_WLANs);
    for i=1:n_WLANs
        [~,index_cca] = find(actions_cca==wlan_aux(i).CCA);
        [~,index_tpc] = find(actions_tpc==wlan_aux(i).PTdBm);
        initial_action_ix_per_wlan(i) = indexes2val(wlan_aux(i).channel, index_cca, index_tpc, size(actions_ch,2), size(actions_cca,2));
    end
    % Initialize the indexes of the taken action
    action_ix_per_wlan = initial_action_ix_per_wlan;                           
    
    % Compute the maximum achievable throughput per WLAN
    power_matrix = PowerMatrix(wlan_aux);     
    upper_bound_tpt_per_wlan = computeMaxBoundThroughput(wlan_aux, power_matrix, noise, max(actions_tpc));

    Qval = {};
    for i=1:n_WLANs
        % Fill the Q-table of each node with 0's 
        Qval{i} = zeros(1, size(possible_actions, 2));
    end
       
    selected_arm = action_ix_per_wlan;              % Initialize arm selection for each WLAN by using the initial action
    current_action = zeros(1, n_WLANs);
    previous_action = selected_arm;
    times_arm_is_seleceted = zeros(n_WLANs, K);     
    transitions_counter = zeros(n_WLANs, K^2);
    allcombs = allcomb(1:K, 1:K);

    %% ITERATE UNTIL CONVERGENCE OR MAXIMUM CONVERGENCE TIME               
    t = 1;
    epsilon = initial_epsilon; 
    cumulative_tpt_experienced_per_WLAN = 0;
    cumulative_fairness = 0;

    while(t < MAX_CONVERGENCE_TIME + 1) 

        % Assign turns to WLANs randomly 
        order = randperm(n_WLANs);  

        for i=1:n_WLANs % Iterate sequentially for each agent in the random order                      

            learning_iteration = 1;
            while(learning_iteration <= MAX_LEARNING_ITERATIONS)
                
                % Select an action according to Q-learning policy
                selected_action = selectActionQLearning(Qval{order(i)}, ...
                    actions_ch, actions_cca, actions_tpc, epsilon);
                               
                ix_action = indexes2val(selected_action(1), selected_action(2), selected_action(3), size(actions_ch,2), size(actions_cca,2));
                
                current_action(order(i)) = ix_action;
                ix = find(allcombs(:,1) == previous_action(order(i)) & allcombs(:,2) == current_action(order(i)));
                previous_action(order(i)) = current_action(order(i));                
                transitions_counter(order(i), ix) = transitions_counter(order(i), ix) + 1;
                
                times_arm_is_seleceted(order(i), ix_action) = times_arm_is_seleceted(order(i), ix_action) + 1;
                
                % Change parameters according to the action obtained
                wlan_aux(order(i)).channel = selected_action(1);   
                %wlan_aux(order(i)).CCA = actions_cca(selected_action(2));
                wlan_aux(order(i)).PTdBm = actions_tpc(selected_action(3));
                
                % Prepare the next state according to the actions performed on the current state
                [~,index_cca] = find(actions_cca==wlan_aux(order(i)).CCA);
                [~,index_tpc] = find(actions_tpc==wlan_aux(order(i)).PTdBm);
                action_ix_per_wlan(order(i)) =  indexes2val(wlan_aux(order(i)).channel, index_cca, ...
                    index_tpc, size(actions_ch,2), size(actions_cca,2));
                               
                % Update the exploration coefficient according to the inputted mode
                if updateMode == 0
                    epsilon = initial_epsilon / t;
                elseif updateMode == 1 
                    epsilon = initial_epsilon / sqrt(t);
                end
                            
                learning_iteration = learning_iteration + 1;
                
            end

        end
        
        power_matrix = PowerMatrix(wlan_aux);        
        tpt_experienced_by_WLAN(t,:) = computeThroughputFromSINR(wlan_aux, power_matrix, noise);  % bps 
                      
        %Update Q   
        for wlan_i = 1 : n_WLANs 
            rw = (tpt_experienced_by_WLAN(t,wlan_i) / upper_bound_tpt_per_wlan(wlan_i));                                      
            Qval{wlan_i}(action_ix_per_wlan(wlan_i)) = ...
                (1 - alpha) * Qval{wlan_i}(action_ix_per_wlan(wlan_i)) + ...
                (alpha * rw + gamma * (max(Qval{wlan_i})));
        end

        cumulative_tpt_experienced_per_WLAN = cumulative_tpt_experienced_per_WLAN +  tpt_experienced_by_WLAN(t,:);
        cumulative_fairness = cumulative_fairness + JainsFairness( tpt_experienced_by_WLAN(t,:));

        % Increase the number of 'learning iterations' of a WLAN
        t = t + 1; 
    
    end
      
    if printInfo
        
        disp('+++++++++++++++++')
        disp('Q-learning execution results per WN:')
        
        % Throughput experienced by each WLAN for each EXP3 iteration
        figure('pos',[450 400 500 350])        
        axes;
        axis([1 20 30 70]);
        % Print the preferred action per wlan
        for i = 1 : n_WLANs      

            times_arm_is_seleceted(i, :)/MAX_CONVERGENCE_TIME;

            [~, ix] = max(Qval{i});
            [a, ~, c] = val2indexes(possible_actions(ix), size(actions_ch,2), size(actions_cca,2), size(actions_tpc,2));  
            disp(['   * WN' num2str(i) ':'])
            disp(['       - Channel:' num2str(a)])
            disp(['       - TPC:' num2str(actions_tpc(c))])
            disp('       - Transitions probabilities (top-3):')
            h(i) = subplot(2, 2, i);
            b = bar(1:K, times_arm_is_seleceted(i, :)/MAX_CONVERGENCE_TIME);
            hold on
            set(gca, 'FontSize', 22, 'Fontname', 'Timesnewroman') 
            axis([0 9 0 1])
            xticks(1:8)
            xticklabels(1:8)
            title(['WN ' num2str(i)])
            xlabel('Action Index', 'FontSize', 18, 'Fontname', 'Timesnewroman')
            ylabel('Probability', 'FontSize', 18, 'Fontname', 'Timesnewroman')
                       
            a = transitions_counter(i,:);
            % Max value
            [val1, ix1] = max(a);
            [ch1_1, ~, x] = val2indexes(possible_actions(allcombs(ix1,1)), size(actions_ch,2), size(actions_cca,2), size(actions_tpc,2)); 
            tpc1_1 = actions_tpc(x);
            [ch1_2, ~, x] = val2indexes(possible_actions(allcombs(ix1,2)), size(actions_ch,2), size(actions_cca,2), size(actions_tpc,2)); 
            tpc1_2 = actions_tpc(x);
            % Second max value
            [val2, ix2] = max(a(a<max(a)));
            [ch2_1, ~, x] = val2indexes(possible_actions(allcombs(ix2,1)), size(actions_ch,2), size(actions_cca,2), size(actions_tpc,2)); 
            tpc2_1 = actions_tpc(x);
            [ch2_2, ~, x] = val2indexes(possible_actions(allcombs(ix2,2)), size(actions_ch,2), size(actions_cca,2), size(actions_tpc,2)); 
            tpc2_2 = actions_tpc(x);
            % Third max value
            [val3, ix3] = max(a(a<max(a(a<max(a)))));
            [ch3_1, ~, x] = val2indexes(possible_actions(allcombs(ix3,1)), size(actions_ch,2), size(actions_cca,2), size(actions_tpc,2)); 
            tpc3_1 = actions_tpc(x);
            [ch3_2, ~, x] = val2indexes(possible_actions(allcombs(ix3,2)), size(actions_ch,2), size(actions_cca,2), size(actions_tpc,2)); 
            tpc3_2 = actions_tpc(x);   

            disp(['              . prob. of going from ' num2str(allcombs(ix1,1)) ' (ch=' num2str(ch1_1) '/tpc=' num2str(tpc1_1) ')' ...
                ' to ' num2str(allcombs(ix1,2)) ' (ch=' num2str(ch1_2) '/tpc=' num2str(tpc1_2) ')' ...
                ' = ' num2str(val1/MAX_CONVERGENCE_TIME)])

            disp(['              . prob. of going from ' num2str(allcombs(ix2,1)) ' (ch=' num2str(ch2_1) '/tpc=' num2str(tpc2_1) ')' ...
                ' to ' num2str(allcombs(ix2,2)) ' (ch=' num2str(ch2_2) '/tpc=' num2str(tpc2_2) ')' ...
                ' = ' num2str(val2/MAX_CONVERGENCE_TIME)])

            disp(['              . prob. of going from ' num2str(allcombs(ix3,1)) ' (ch=' num2str(ch3_1) '/tpc=' num2str(tpc3_1) ')' ...
                ' to ' num2str(allcombs(ix3,2)) ' (ch=' num2str(ch3_2) '/tpc=' num2str(tpc3_2) ')' ...
                ' = ' num2str(val3/MAX_CONVERGENCE_TIME)])

        end
        
        disp('+++++++++++++++++')
        
    end
    
end