% Decentralized_Qlearning_Resource_Allocation_in_WNs

%   Francesc Wilhelmi, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Boris Bellalta, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Cristina Cano, Wireless Networks Research Group (WINE-UOC), Universitat Oberta de Catalunya (UOC)
%   Anders Jonsson, Artificial Intelligence and Machine Learning Research Group (AIML-UPF), Universitat Pompeu Fabra (UPF)

function tpt = computeThroughputFromSINR(wlan, powMat, noise)
% Computes the throughput of each WLAN in wlan according to the
% interferences sensed 
%  * Assumption: all the devices transmit at the same time and the
%    throughput is computed as the capacity obtained from the total SINR 
%
% OUTPUT:
%   * tpt - tpt achieved by each WLAN (Mbps)
% INPUT:
%   * wlan - object containing all the WLANs information 
%   * powMat - power received from each AP
%   * noise - floor noise in dBm

    N_WLANs = size(wlan,2);
    sinr = zeros(1,N_WLANs);  
    % Activate all the WLANs
    for j = 1:N_WLANs, wlan(j).transmitting = 1; end
    % Compute the tpt of each WLAN according to the sensed interferences
    for i = 1:N_WLANs
        interferences = Interferences(wlan, powMat); %dBm                      
        sinr(i) = powMat(i,i) - pow2db((interferences(i) + db2pow(noise))); % dBm
        tpt(i) = computeTheoreticalCapacity(wlan(i).BW, db2pow(sinr(i))) / 1e6; % Mbps     
    end
    
end