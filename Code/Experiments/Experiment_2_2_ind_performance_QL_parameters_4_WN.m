% Decentralized_Qlearning_Resource_Allocation_in_WNs

%   Francesc Wilhelmi, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Boris Bellalta, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Cristina Cano, Wireless Networks Research Group (WINE-UOC), Universitat Oberta de Catalunya (UOC)
%   Anders Jonsson, Artificial Intelligence and Machine Learning Research Group (AIML-UPF), Universitat Pompeu Fabra (UPF)

% EXPERIMENT EXPLANATION:
% By using a simple grid of 4 WLANs sharing 2 channels, we want to test the
% Q-learning method if using different numbers of iterations. We fix alpha,
% gamma and initial epsilon to the values that generated better results in
% terms of proportional fairness in the Experiment_1

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
disp('EXPERIMENT 2-2: Individual performance Q-learning')
disp('-----------------------')

%% DEFINE THE VARIABLES TO BE USED

% GLOBAL VARIABLES
n_WLANs = 4;                    % Number of WLANs in the map
n_agents = 4;                   % Number of WLANs implementing Q-learning
MAX_CONVERGENCE_TIME = 10000;   % Maximum convergence time (one period implies the participation of all WLANs)
MIN_SAMPLE_CONSIDER = 1;        % Iteration from which to consider the obtained results
MAX_LEARNING_ITERATIONS = 1;    % Maximum number of learning iterations done by each WLAN inside a general iteration
TOTAL_ROUNDS = 1;               % Number of TOTAL repetitions to take the average
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
gamma = .95;            % Discount rate
initial_epsilon = .1;   % Initial Exploration coefficient
updateMode = 1;         % 0: epsilon = initial_epsilon / t ; 1: epsilon = epsilon / sqrt(t)
alpha  = 1;             % Learning rate

printInfo = 1;          % print info when calling QlearningMethod

% Setup the scenario: generate WLANs and initialize states and actions
wlan = GenerateNetwork3D(n_WLANs, nChannels, 'grid', 2, 0); % SAFE CONFIGURATION
    
% Compute the throughput experienced per WLAN at each iteration                             
[tpt_evolution_per_wlan_ql, ~] = QlearningMethod(wlan, MAX_CONVERGENCE_TIME, MAX_LEARNING_ITERATIONS, ...
        gamma, initial_epsilon, alpha, updateMode, actions_ch, actions_cca, actions_tpc, noise, printInfo);

%% PLOT THE RESULTS
disp(['Aggregate throughput experienced on average: ' num2str(mean(sum(tpt_evolution_per_wlan_ql(MIN_SAMPLE_CONSIDER:MAX_CONVERGENCE_TIME, :),2)))])
disp(['Fairness on average: ' num2str(mean(JainsFairness(tpt_evolution_per_wlan_ql(MIN_SAMPLE_CONSIDER:MAX_CONVERGENCE_TIME, :))))])
disp(['Proportional fairness experienced on average: ' num2str(mean(sum(log(tpt_evolution_per_wlan_ql(MIN_SAMPLE_CONSIDER:MAX_CONVERGENCE_TIME, :)),2)))])

% Throughput experienced by each WLAN for each EXP3 iteration
figure('pos',[450 400 500 350])
axes;
axis([1 20 30 70]);
for i = 1:n_WLANs
    subplot(n_WLANs/2, n_WLANs/2, i)
    tpt_per_iteration = tpt_evolution_per_wlan_ql(MIN_SAMPLE_CONSIDER:MAX_CONVERGENCE_TIME, i);
    plot(MIN_SAMPLE_CONSIDER:MAX_CONVERGENCE_TIME, tpt_per_iteration);
    title(['WN ' num2str(i)]);
    set(gca, 'FontSize', 22)
    axis([MIN_SAMPLE_CONSIDER-1 MAX_CONVERGENCE_TIME 0 1.1 * max(tpt_per_iteration)])
    ylabel('Throughput', 'fontsize', 18)
    xlabel('Q-learning iteration', 'fontsize', 18)
    set(gca, 'fontname', 'timesnewroman')
end

% Aggregated throughput experienced for each EXP3 iteration
figure('pos',[450 400 500 350])
axes;
axis([1 20 30 70]);
agg_tpt_per_iteration = sum(tpt_evolution_per_wlan_ql(MIN_SAMPLE_CONSIDER:MAX_CONVERGENCE_TIME, :), 2);
plot(MIN_SAMPLE_CONSIDER:MAX_CONVERGENCE_TIME, agg_tpt_per_iteration)
set(gca, 'FontSize', 22)
xlabel('Q-learning Iteration', 'fontsize', 24)
ylabel('Network Throughput (Mbps)', 'fontsize', 24)
axis([MIN_SAMPLE_CONSIDER-1 MAX_CONVERGENCE_TIME 0 1.1 * max(agg_tpt_per_iteration)])
set(gca, 'fontname', 'timesnewroman')

% Proportional fairness experienced for each EXP3 iteration
figure('pos',[450 400 500 350])
axes;
axis([1 20 30 70]);
proprotional_fairness_per_iteration = sum(log(tpt_evolution_per_wlan_ql(MIN_SAMPLE_CONSIDER:MAX_CONVERGENCE_TIME,:)), 2);
plot(MIN_SAMPLE_CONSIDER:MAX_CONVERGENCE_TIME, proprotional_fairness_per_iteration)
set(gca, 'FontSize', 22)
xlabel('Q-learning Iteration', 'fontsize', 24)
ylabel('Proportional Fairness', 'fontsize', 24)
axis([MIN_SAMPLE_CONSIDER-1 MAX_CONVERGENCE_TIME 0 1.1 * max(proprotional_fairness_per_iteration)])
set(gca, 'fontname', 'timesnewroman')

% Average tpt experienced per WLAN
MIN_SAMPLE_CONSIDER = MAX_CONVERGENCE_TIME/2 + 1;
mean_tpt_per_wlan = mean(tpt_evolution_per_wlan_ql(MIN_SAMPLE_CONSIDER:MAX_CONVERGENCE_TIME,:),1);
std_per_wlan = std(tpt_evolution_per_wlan_ql(MIN_SAMPLE_CONSIDER:MAX_CONVERGENCE_TIME,:),1);
figure('pos',[450 400 500 350])
axes;
axis([1 20 30 70]);
bar(mean_tpt_per_wlan, 0.5)
set(gca, 'FontSize', 22)
xlabel('WN id','fontsize', 24)
ylabel('Mean throughput (Mbps)', 'fontsize', 24)
hold on
errorbar(mean_tpt_per_wlan,std_per_wlan, '.r');
axis([0 5 0 350])
set(gca, 'fontname', 'timesnewroman')

save('ql_exp2_2_workspace.mat')