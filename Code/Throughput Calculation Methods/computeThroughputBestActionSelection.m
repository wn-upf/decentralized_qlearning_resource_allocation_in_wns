% Decentralized_Qlearning_Resource_Allocation_in_WNs

%   Francesc Wilhelmi, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Boris Bellalta, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Cristina Cano, Wireless Networks Research Group (WINE-UOC), Universitat Oberta de Catalunya (UOC)
%   Anders Jonsson, Artificial Intelligence and Machine Learning Research Group (AIML-UPF), Universitat Pompeu Fabra (UPF)

function tpt_per_wlan = computeThroughputBestActionSelection(wlan, actions_ch, actions_cca, actions_tpc, noise, maxIter)
% Computes the throughput for each WLAN if each one sequentially tries all 
% its possible combinations once and then selects the one that provides higher throughput
%
% OUTPUT:
%   * tpt_per_wlan - throughput in Mbps obtained by each WLAN after all
%   changed their configuration
% INPUT:
%   * wlan - object containing all the information of the WLANs
%   * actions_ch - set of channels
%   * actions_cca - set of carrier sense thresholds
%   * actions_tpc - set of transmit power values
%   * noise - floor noise in dBm
%   * maxIter - number of iterations for applying Best Action Selection

    % Each state represents an [i,j,k] combination for indexes on "channels", "CCA" and "TxPower"
    possible_actions = 1:(size(actions_ch,2)*size(actions_cca,2)*size(actions_tpc,2));
    % Total number of actions
    K = size(possible_actions,2);

    n_WLANs = size(wlan,2);
    nChannels = size(actions_ch, 2);
    
    wlan_aux = wlan;

    % Apply the algorithm sequentially for each WLAN
    iteration = 1;
    tpt_best_action = zeros(1, n_WLANs);
    best_action = zeros(1, n_WLANs);

    % CALCULATE TPT FOR EACH WLAN 
    powMat = PowerMatrix(wlan_aux);            
    tpt_start = computeTptPowMat(wlan_aux, powMat, noise); 
    avg_tpt_start = mean(tpt_start);
    fairness_start = JainsFairness(tpt_start);     

    while(iteration < maxIter + 1)    
        % Iterate for all the WLANs
        order = randperm(n_WLANs); 
        for i = 1:n_WLANs
            tpt_per_action = zeros(1,K);
            % Iterate for all the possible actions 
            for j = 1:K                
                % Choose action j 
                [ch, ~, tpc_ix] = val2indexes(j, nChannels, size(actions_cca,2), size(actions_tpc,2));
                wlan_aux(order(i)).channel = ch;   
                wlan_aux(order(i)).PTdBm = actions_tpc(tpc_ix);
                % Compute the resulting tpt
                powMat = PowerMatrix(wlan_aux); %
                tpt_after_action = computeTptPowMat(wlan_aux, powMat, noise); 
                tpt_per_action(j) = tpt_after_action(order(i));
            end
            % Choose the action that provided highest throughput
            [tpt_best_action(order(i)), best_action(order(i))] = max(tpt_per_action);
            [ch, ~, tpc_ix] = val2indexes(best_action(order(i)), size(actions_ch,2), size(actions_cca,2), size(actions_tpc,2));
            wlan_aux(order(i)).channel = ch;   
            wlan_aux(order(i)).PTdBm = actions_tpc(tpc_ix); 
        end
        iteration = iteration + 1;    
    end 

    % Once all the WLANs chose the best action and compute the average tpt
    powMat = PowerMatrix(wlan_aux); %
    tpt_best_action = computeTptPowMat(wlan_aux, powMat, noise);
    avg_tpt_end = mean(tpt_best_action);
    fairness_end = JainsFairness(tpt_best_action);       

    disp(['Network Throughput at the beginning = ' num2str(avg_tpt_start) ' Mbps'])
    disp(['Fariness at the beginning = ' num2str(fairness_start)])
    disp(['Network Throughput at the end = ' num2str(avg_tpt_end) ' Mbps'])
    disp(['Fairness at the end = ' num2str(fairness_end)])

    tpt_per_wlan = tpt_best_action;
    
end