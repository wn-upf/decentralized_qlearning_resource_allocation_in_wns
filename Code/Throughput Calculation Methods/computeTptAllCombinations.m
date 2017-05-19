% Decentralized_Qlearning_Resource_Allocation_in_WNs

%   Francesc Wilhelmi, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Boris Bellalta, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Cristina Cano, Wireless Networks Research Group (WINE-UOC), Universitat Oberta de Catalunya (UOC)
%   Anders Jonsson, Artificial Intelligence and Machine Learning Research Group (AIML-UPF), Universitat Pompeu Fabra (UPF)

function tpt_wlan_per_conf = computeTptAllCombinations(wlan, actions_ch, actions_cca, actions_tpc, noise)
% Computes the throughput experienced by each WLAN for all the possible
% combinations of Channels, CCA and TPC 
%
%   NOTE: the "allcomb" function does not hold big amounts of combinations 
%   (a reasonable limit is 4 WLANs with 2 channels and 4 levels of TPC)
%
% OUTPUT:
%   * tpt - tpt achieved by each WLAN for each configuration (Mbps)
% INPUT:
%   * wlan - object containing all the WLANs information 
%   * actions_ch - set of channels
%   * actions_cca - set of carrier sense thresholds
%   * actions_tpc - set of transmit power values
%   * noise - floor noise in dBm

    disp('      - Computing the throughput for all the combinations...')

    % Each state represents an [i,j,k] combination for indexes on "channels", "CCA" and "TxPower"
    possible_actions = 1:(size(actions_ch,2)*size(actions_cca,2)*size(actions_tpc,2));
    % Set of possible combinations of configuration  
    possible_comb = allcomb(possible_actions,possible_actions,possible_actions,possible_actions);

    n_WLANs = size(wlan,2);
    nChannels = size(actions_ch, 2);
    
    wlan_aux = wlan;    % Generate a copy of the WLAN object to make modifications

    % Try all the combinations
    for i = 1:size(possible_comb, 1)
        % Change WLANs configuration 
        for j = 1:n_WLANs 
            [ch, ~, tpc_ix] = val2indexes(possible_comb(i,j), nChannels, size(actions_cca,2), size(actions_tpc,2));
            wlan_aux(j).channel = ch;   
            wlan_aux(j).PTdBm = actions_tpc(tpc_ix);            
        end
        % Compute the Throughput and store it
        power_matrix = PowerMatrix(wlan_aux); 
        tpt_wlan_per_conf(i,:) = computeThroughputFromSINR(wlan_aux, power_matrix, noise); 
    end
    
    % Find the best configuration for each WLAN and display it
    for i = 1:size(tpt_wlan_per_conf, 1)
        agg_tpt(i) = sum(tpt_wlan_per_conf(i,:));
        fairness(i) = JainsFairness(tpt_wlan_per_conf(i,:));
        prop_fairness(i) = sum(log(tpt_wlan_per_conf(i,:)));
    end    
    
    [val, ix] = max(prop_fairness);
    disp('---------------')
    disp(['Best proportional fairness: ' num2str(val)])
    disp(['Aggregate throughput: ' num2str(agg_tpt(ix)) ' Mbps'])
    disp(['Fairness: ' num2str(fairness(ix))])
    disp(['Best configurations: ' num2str(possible_comb(ix, :))])
    for i = 1:n_WLANs
        [a, ~, c] = val2indexes(possible_comb(ix, i), nChannels, size(actions_cca, 2), size(actions_tpc, 2));  
        disp(['   * WLAN' num2str(i) ':'])
        disp(['       - Channel:' num2str(a)])
        disp(['       - TPC:' num2str(actions_tpc(c))])
    end
    
    
    [val2, ix2] = max(agg_tpt);
    disp('---------------')
    disp(['Best aggregate throughput: ' num2str(val2) ' Mbps'])
    disp(['Fairness: ' num2str(fairness(ix2))])
    disp(['Best configurations: ' num2str(possible_comb(ix2, :))])
    for i = 1:n_WLANs
        [a, ~, c] = val2indexes(possible_comb(ix2, i), nChannels, size(actions_cca, 2), size(actions_tpc, 2));  
        disp(['   * WLAN' num2str(i) ':'])
        disp(['       - Channel:' num2str(a)])
        disp(['       - TPC:' num2str(actions_tpc(c))])
    end
    
end