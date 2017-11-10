% Decentralized_Qlearning_Resource_Allocation_in_WNs

%   Francesc Wilhelmi, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Boris Bellalta, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Cristina Cano, Wireless Networks Research Group (WINE-UOC), Universitat Oberta de Catalunya (UOC)
%   Anders Jonsson, Artificial Intelligence and Machine Learning Research Group (AIML-UPF), Universitat Pompeu Fabra (UPF)

function ix = indexes2val(i,j,k,a,b)
% indexes2val provides the index ix from i, j, k (value for each variable)
%   OUTPUT: 
%       * ix - index of the (i,j,k) combination
%   INPUT: 
%       * i - index of the first element
%       * j - index of the second element
%       * k - index of the third element
%       * a - size of elements containing "i"
%       * b - size of elements containing "j"
%           (size of elements containing "k" is not necessary)

    ix = i + (j-1)*a + (k-1)*a*b;
    
end