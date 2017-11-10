% Decentralized_Qlearning_Resource_Allocation_in_WNs

%   Francesc Wilhelmi, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Boris Bellalta, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Cristina Cano, Wireless Networks Research Group (WINE-UOC), Universitat Oberta de Catalunya (UOC)
%   Anders Jonsson, Artificial Intelligence and Machine Learning Research Group (AIML-UPF), Universitat Pompeu Fabra (UPF)

function fairness = JainsFairness(C)
% JainsFairness returns the Jain's fairness measure given the inputted array
%   OUTPUT: 
%       * fairness - Jain's fairness measure from 0 to 1
%   INPUT: 
%       * C - array of capacities that each WLAN experiences

    numRows = size(C, 1);
    
    for i = 1:numRows
        fairness(i) = sum(C(i,:))^2 ./ (size(C(i,:),2)*sum(C(i,:).^2));
    end

end