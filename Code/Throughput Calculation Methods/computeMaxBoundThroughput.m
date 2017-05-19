% Decentralized_Qlearning_Resource_Allocation_in_WNs

%   Francesc Wilhelmi, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Boris Bellalta, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Cristina Cano, Wireless Networks Research Group (WINE-UOC), Universitat Oberta de Catalunya (UOC)
%   Anders Jonsson, Artificial Intelligence and Machine Learning Research Group (AIML-UPF), Universitat Pompeu Fabra (UPF)

function optimal_tpt = computeMaxBoundThroughput(wlan, powMat, noise, maxPower)
% Given an WLAN (AP+STA), compute the maximum capacity achievable according
% to the power obtained at the receiver without interference
%
% OUTPUT:
%   * optimal_tpt - maximum achievable throughput per WLAN (Mbps)
% INPUT:
%   * wlan - object containing all the WLANs information 
%   * powMat - power received from each AP
%   * noise - floor noise in dBm

    wlan_aux = wlan;
    for i=1:size(wlan_aux,2)
        wlan_aux(i).PTdBm = maxPower;
        optimal_tpt(i) = computeTheoreticalCapacity(wlan_aux(i).BW, db2pow(powMat(i,i) - noise))/1e6; % Mbps
    end
    
end