% Decentralized_Qlearning_Resource_Allocation_in_WNs

%   Francesc Wilhelmi, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Boris Bellalta, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Cristina Cano, Wireless Networks Research Group (WINE-UOC), Universitat Oberta de Catalunya (UOC)
%   Anders Jonsson, Artificial Intelligence and Machine Learning Research Group (AIML-UPF), Universitat Pompeu Fabra (UPF)

% EXPERIMENT EXPLANATION:
% By using a simple grid of 4 WLANs sharing 2 channels, we want to test several values of
% gamma, alpha and initial epsilon to evaluate the performance of
% Q-learning for each of them. We compare the obtained results with the
% optimal configurations in terms of proportional fairness and aggregate
% throughput.

clc
clear all

% Add paths to methods folders
addpath(genpath('framework_throughput_total_interference/'));
addpath(genpath('framework_throughput_total_interference/power_management_methods/'));
addpath(genpath('framework_throughput_total_interference/throughput_calculation_methods/'));
addpath(genpath('framework_throughput_total_interference/network_generation_methods/'));
addpath(genpath('framework_throughput_total_interference/auxiliary_methods/'));
addpath(genpath('reinforcement_learning_methods/'));
addpath(genpath('reinforcement_learning_methods/action_selection_methods/'));

disp('****************************************************************************************');
disp('* Implications of Decentralized Learning Resource Allocation in WNs                    *');
disp('* Copyright (C) 2017-2022, and GNU GPLd, by Francesc Wilhelmi                          *');
disp('* GitHub: https://github.com/wn-upf/Decentralized_Qlearning_Resource_Allocation_in_WNs *');
disp('`****************************************************************************************');

disp('-----------------------')
disp('EXPERIMENT 1-1: finding the best parameters (Q-learning)')
disp('-----------------------')

%% DEFINE THE VARIABLES TO BE USED

% GLOBAL VARIABLES
n_WLANs = 4;                    % Number of WLANs in the map
n_agents = 4;                   % Number of WLANs implementing Q-learning
MAX_CONVERGENCE_TIME = 10000;
MIN_SAMPLE_CONSIDER = MAX_CONVERGENCE_TIME/2 + 1;
MAX_LEARNING_ITERATIONS = 1;    % Maximum number of learning iterations done by each WLAN inside a general iteration
TOTAL_ROUNDS = 100;               % Number of TOTAL repetitions to take the average
plot_results = 0;               % To plot or not the results at the end of the simulation

% WLAN object to be modified for each number of coexistent nodes
global wlan
nChannels = 2;              % Number of available channels (from 1 to NumChannels)
noise = -100;               % Floor noise (dBm)

% Definition of actions:
global actions_ch actions_cca actions_tpc
actions_ch = 1:nChannels;       % nChannels possible channels
actions_cca = [-82];            % One CCA level (dBm) -> meaningless (all interferences are considered)
actions_tpc = [5 10 15 20];     % 4 different levels of TPC (dBm)

% Each state represents an [i,j,k] combination for indexes on "channels", "CCA" and "TxPower"
global possible_actions
possible_actions = 1:(size(actions_ch,2)*size(actions_cca,2)*size(actions_tpc,2));
% Total number of actions
K = size(possible_actions,2);
% All possible combinations of configurations for the entire scenario
possible_comb = allcomb(possible_actions,possible_actions,possible_actions,possible_actions);

% Q-learning parameters
initial_epsilon = 1;    % Initial Exploration coefficient
updateMode = 1;         % 0: epsilon = initial_epsilon / t ; 1: epsilon = epsilon / sqrt(t)

gamma_epsilon_pairs = [.95 1; 0.5 1; .05 1; .95 .5; .5 .5; .05 .5];
alpha = 0:.1:1;                 % Learning Rate

printInfo = true;      % print info after implementing Q-learning

% Setup the scenario: generate WLANs and initialize states and actions
wlan = GenerateNetwork3D(n_WLANs, nChannels, 'grid', 2, 0); % SAFE CONFIGURATION
%DrawNetwork3D(wlan)
    
%% ITERATE FOR NUMBER OF REPETITIONS (TO TAKE THE AVERAGE) 
tpt_evolution_per_wlan_ql = cell(1, TOTAL_ROUNDS);

avg_tpt_evolution_ql = cell(1, TOTAL_ROUNDS);
fairness_evolution = cell(1, TOTAL_ROUNDS);

avg_tpt_experienced_ql = cell(1, TOTAL_ROUNDS);
std_tpt_experienced_ql = cell(1, TOTAL_ROUNDS);

aggregate_tpt = cell(1, TOTAL_ROUNDS);

avg_fairness_experienced = cell(1, TOTAL_ROUNDS);

for iter = 1:TOTAL_ROUNDS

    disp('------------------------------------')
    disp(['ROUND ' num2str(iter) '/' num2str(TOTAL_ROUNDS)])
    disp('------------------------------------')

    for a = 1 : size(alpha,2)

        for g_e = 1 : size(gamma_epsilon_pairs,1)

            tpt_evolution_per_wlan_ql{iter}  = QlearningMethod(wlan, MAX_CONVERGENCE_TIME, MAX_LEARNING_ITERATIONS, ...
                                            gamma_epsilon_pairs(g_e, 1), gamma_epsilon_pairs(g_e, 2), alpha(a), updateMode, ...
                                            actions_ch, actions_cca, actions_tpc, noise, printInfo);
                                        
            for j = 1 : MAX_CONVERGENCE_TIME
                avg_tpt_evolution_ql{iter}(j) = mean(tpt_evolution_per_wlan_ql{iter}(j,:));
                fairness_evolution{iter}(j) = JainsFairness(tpt_evolution_per_wlan_ql{iter}(j,:));
            end

            avg_tpt_experienced_ql{iter}(a, g_e) = mean(avg_tpt_evolution_ql{iter}(MIN_SAMPLE_CONSIDER:MAX_CONVERGENCE_TIME));              
            std_tpt_experienced_ql{iter}(a, g_e) = std(avg_tpt_evolution_ql{iter}(MIN_SAMPLE_CONSIDER:MAX_CONVERGENCE_TIME)); 

            aggregate_tpt{iter}(a, g_e) = mean(sum(tpt_evolution_per_wlan_ql{iter}(MIN_SAMPLE_CONSIDER:MAX_CONVERGENCE_TIME, :), 2));
            avg_fairness_experienced{iter}(a, g_e) = mean(sum(fairness_evolution{iter}(MIN_SAMPLE_CONSIDER:MAX_CONVERGENCE_TIME), 2));
            
        end

    end

end

%% PLOT THE RESULTS

% Compute the optimal configuration to compare the approaches
maximum_achievable_throughput = computeTptAllCombinations(wlan, actions_ch, actions_cca, actions_tpc, noise);
% Find the best configuration for each WLAN and display it
for i = 1:size(maximum_achievable_throughput,1)
    best_conf_tpt(i) = sum(maximum_achievable_throughput(i,:));
    best_conf_fairness(i) = sum(log(maximum_achievable_throughput(i,:)));
end    

[optimal_prop_fairness, ix] = max(best_conf_fairness);
disp('---------------')
disp(['Best proportional fairness: ' num2str(optimal_prop_fairness)])
disp(['Best configurations: ' num2str(possible_comb(ix,:))])
for i = 1:n_WLANs
    [a, ~, c] = val2indexes(possible_comb(ix,i), nChannels, size(actions_cca,2), size(actions_tpc,2));  
    disp(['   * WLAN' num2str(i) ':'])
    disp(['       - Channel:' num2str(a)])
    disp(['       - TPC:' num2str(actions_tpc(c))])
end

[optimal_agg_tpt, ix2] = max(best_conf_tpt);
disp('---------------')
disp(['Best aggregate throughput: ' num2str(optimal_agg_tpt) ' Mbps'])
disp(['Best configurations: ' num2str(possible_comb(ix2,:))])
for i = 1:n_WLANs
    [a, ~, c] = val2indexes(possible_comb(ix2,i), nChannels, size(actions_cca,2), size(actions_tpc,2));  
    disp(['   * WLAN' num2str(i) ':'])
    disp(['       - Channel:' num2str(a)])
    disp(['       - TPC:' num2str(actions_tpc(c))])
end

% Maximum value and index:
% [maxVal,ix] = max(aggregate_tpt{1}(:));
% [m,n] = ind2sub(size(aggregate_tpt{1}),ix);
% disp(['Best alpha = ' num2str(alpha(m))]);
% disp(['Best gamma/epsilon = ' num2str(gamma_epsilon_pairs(n, :))]);

% Compute the average results found for the aggregated throughput
aux_array = zeros(size(alpha, 2), size(gamma_epsilon_pairs, 1));
for a = 1 : size(alpha, 2)     
    for g_e = 1 : size(gamma_epsilon_pairs, 1)
        for i = 1 : TOTAL_ROUNDS
            aux_array(a, g_e) = aux_array(a, g_e) + aggregate_tpt{i}(a, g_e);
        end
    end
end
mean_aggregate_tpt = aux_array / TOTAL_ROUNDS;
disp('mean_aggregate_tpt')
disp(mean_aggregate_tpt)
% Compute the standard deviation for the aggregated throughput
aux_array_std = zeros(size(alpha, 2), size(gamma_epsilon_pairs, 1));
for a = 1 : size(alpha, 2)     
    for g_e = 1 : size(gamma_epsilon_pairs, 1)
        for i = 1:TOTAL_ROUNDS
            aux_array_std(a, g_e) = aux_array_std(a, g_e) + ((aggregate_tpt{i}(a, g_e) - mean_aggregate_tpt(a, g_e))^2);
        end
    end
end
std_aggregate_tpt = sqrt(aux_array_std / TOTAL_ROUNDS);
disp('std_aggregate_tpt')
disp(std_aggregate_tpt)
 
% Plot the results
l = {};
figure('pos', [450 400 500 350])
axes;
axis([1 20 30 70]);
for i=1:size(gamma_epsilon_pairs,1)
    plot(alpha, mean_aggregate_tpt(:,i), r{i})
    hold on
    l = [l ['\gamma = ' num2str(gamma_epsilon_pairs(i,1)) ' \epsilon_{0} = ' num2str(gamma_epsilon_pairs(i,2))]];
    errorbar(alpha, mean_aggregate_tpt(:,i)', std_aggregate_tpt(:,i)')
    xticks(alpha)
end
plot(alpha, optimal_agg_tpt*ones(1, size(alpha,2)),'--r','linewidth',2);
legend(l)
set(gca, 'FontSize', 22)
ylabel('Network Throughput (Mbps)', 'FontSize', 24, 'fonttype', 'timesnewroman')
xlabel('\alpha', 'FontSize', 24)
axis([0 1 0 1.2 * max(max(mean_aggregate_tpt))])
grid on
set(gca, 'font', 'timesnewroman')

save('ql_exp1_workspace.mat')