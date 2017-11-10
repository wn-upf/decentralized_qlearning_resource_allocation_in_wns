% Decentralized_Qlearning_Resource_Allocation_in_WNs

%   Francesc Wilhelmi, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Boris Bellalta, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Cristina Cano, Wireless Networks Research Group (WINE-UOC), Universitat Oberta de Catalunya (UOC)
%   Anders Jonsson, Artificial Intelligence and Machine Learning Research Group (AIML-UPF), Universitat Pompeu Fabra (UPF)

% EXPERIMENT EXPLANATION:
% By using a simple grid of 4 WLANs sharing 2 channels, we want to test several values of
% gamma and alpha to see their relation.

%%
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
disp('****************************************************************************************');

disp('-----------------------')
disp('EXPERIMENT 1-2: Alpha vs Gamma performance (Q-learning)')
disp('-----------------------')

%% DEFINE THE VARIABLES TO BE USED

% GLOBAL VARIABLES
n_WLANs = 4;                    % Number of WLANs in the map
n_agents = 4;                   % Number of WLANs implementing Q-learning
MAX_CONVERGENCE_TIME = 10000;
MIN_SAMPLE_CONSIDER = MAX_CONVERGENCE_TIME/2 + 1;
MAX_LEARNING_ITERATIONS = 1;    % Maximum number of learning iterations done by each WLAN inside a general iteration
TOTAL_ROUNDS = 100;             % Number of TOTAL repetitions to take the average
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
possible_comb = allcomb(possible_actions,possible_actions,possible_actions,possible_actions);

% Q-learning parameters
initial_epsilon = 1;    % Initial Exploration coefficient
updateMode = 1;         % 0: epsilon = initial_epsilon / t ; 1: epsilon = epsilon / sqrt(t) 

gamma = 0:.1:1;         % Discount factor
alpha = 0:.1:1;         % Learning Rate

printInfo = false;      % print info after implementing Q-learning

% Setup the scenario: generate WLANs and initialize states and actions
wlan = GenerateNetwork3D(n_WLANs, nChannels, 'grid', 2, 0); % SAFE CONFIGURATION
%DrawNetwork3D(wlan)
    
%% ITERATE FOR NUMBER OF REPETITIONS (TO TAKE THE AVERAGE)
    
for iter = 1:TOTAL_ROUNDS

    disp('------------------------------------')
    disp(['ROUND ' num2str(iter) '/' num2str(TOTAL_ROUNDS)])
    disp('------------------------------------')

    for a = 1:size(alpha,2)

        for g = 1:size(gamma,2)

            tpt_evolution_per_wlan_ql{iter}  = QlearningMethod(wlan,...
                MAX_CONVERGENCE_TIME, MAX_LEARNING_ITERATIONS, gamma(g), ...
                initial_epsilon, alpha(a), updateMode, actions_ch, ...
                actions_cca, actions_tpc, noise, printInfo);

            for j=1:MAX_CONVERGENCE_TIME
                avg_tpt_evolution_ql{iter}(j) = mean(tpt_evolution_per_wlan_ql{iter}(j,:));
            end
            
            avg_tpt_experienced_ql{iter}(a, g) = mean(avg_tpt_evolution_ql{iter}(MIN_SAMPLE_CONSIDER:MAX_CONVERGENCE_TIME));
            std_tpt_experienced_ql{iter}(a, g) = std(avg_tpt_evolution_ql{iter}(MIN_SAMPLE_CONSIDER:MAX_CONVERGENCE_TIME)); 

            aggregate_tpt{iter}(a, g) = mean(sum(tpt_evolution_per_wlan_ql{iter}(MIN_SAMPLE_CONSIDER:MAX_CONVERGENCE_TIME, :), 2));
    
        end

    end

end

%% PLOT THE RESULTS

% Compute the average results found for the aggregated throughput
aux_array = zeros(size(alpha, 2), size(gamma, 2));
for a = 1 : size(alpha, 2)     
    for g = 1 : size(gamma, 2)
        for i = 1 : TOTAL_ROUNDS
            aux_array(a, g) = aux_array(a, g) + aggregate_tpt{i}(a, g);
        end
    end
end
mean_aggregate_tpt = aux_array / TOTAL_ROUNDS;
disp('mean_aggregate_tpt')
disp(mean_aggregate_tpt)
% Compute the standard deviation for the aggregated throughput
aux_array_std = zeros(size(alpha, 2), size(gamma, 2));
for a = 1 : size(alpha, 2)     
    for g = 1 : size(gamma, 2)
        for i = 1:TOTAL_ROUNDS
            aux_array_std(a, g) = aux_array_std(a, g) + ((aggregate_tpt{i}(a, g) - mean_aggregate_tpt(a, g))^2);
        end
    end
end
std_aggregate_tpt = sqrt(aux_array_std / TOTAL_ROUNDS);
disp('std_aggregate_tpt')
disp(std_aggregate_tpt)


% PLOT THE RESULTS
[maxVal, ix_alpha] = max(mean_aggregate_tpt(:));
[m, n] = ind2sub(size(mean_aggregate_tpt), ix_alpha);

disp(['Best alpha-gamma values: ' num2str(alpha(n)) ' - ' num2str(gamma(m))])

figure('pos',[450 400 500 350])
axes;
axis([1 20 30 70]);
surf(alpha, gamma, mean_aggregate_tpt)
xlabel('\gamma','FontSize', 24)
ylabel('\alpha','FontSize', 24)
zlabel('Network Throughput (Mbps)','FontSize', 24)
set(gca, 'FontSize', 22, 'FontName', 'timesnewroman')
%plot3(alpha(n), gamma(m), maxVal, 'ro', 'markersize', 20);

[maxVal, ix_alpha] = max(std_aggregate_tpt(:));
[m, n] = ind2sub(size(std_aggregate_tpt), ix_alpha);

figure('pos',[450 400 500 350])
axes;
axis([1 20 30 70]);
surf(alpha, gamma, std_aggregate_tpt)
xlabel('\gamma','FontSize', 24)
ylabel('\alpha','FontSize', 24)
zlabel('Standard Deviation (Mbps)','FontSize', 24)
set(gca, 'FontSize', 22, 'FontName', 'timesnewroman')
hold on
%plot3(alpha(n), gamma(m), maxVal, 'ro', 'markersize', 20);

save('ql_exp3_workspace.mat')