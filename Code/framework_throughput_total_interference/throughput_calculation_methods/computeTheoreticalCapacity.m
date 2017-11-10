% Decentralized_Qlearning_Resource_Allocation_in_WNs

%   Francesc Wilhelmi, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Boris Bellalta, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Cristina Cano, Wireless Networks Research Group (WINE-UOC), Universitat Oberta de Catalunya (UOC)
%   Anders Jonsson, Artificial Intelligence and Machine Learning Research Group (AIML-UPF), Universitat Pompeu Fabra (UPF)

function C = computeTheoreticalCapacity(B, sinr)
% Computes the theoretical capacity given a bandwidth and a SINR
%
% OUTPUT:
%   * C - capacity in bps
% INPUT:
%   * B - Available Bandwidth (Hz) 
%   * sinr - Signal to Interference plus Noise Ratio (-)

    C = B * log2(1+sinr);

end