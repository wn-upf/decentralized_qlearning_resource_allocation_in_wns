% Decentralized_Qlearning_Resource_Allocation_in_WNs

%   Francesc Wilhelmi, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Boris Bellalta, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Cristina Cano, Wireless Networks Research Group (WINE-UOC), Universitat Oberta de Catalunya (UOC)
%   Anders Jonsson, Artificial Intelligence and Machine Learning Research Group (AIML-UPF), Universitat Pompeu Fabra (UPF)

function [i,j,k] = val2indexes(ix, a, b, c)
% val2indexes provides the indexes i,j,k from index ix
%   OUTPUT: 
%       * i - index of the first element
%       * j - index of the second element
%       * k - index of the third element
%   INPUT: 
%       * ix - index of the (i,j,k) combination
%       * a - size of elements containing "i"
%       * b - size of elements containing "j"
%       * c - size of elements containing "k"

    i = mod(ix, a); 
    if i == 0, i = a; end    
    y = mod(ix, (a * b));
    j = ceil(y/a);
    if j == 0, j = b; end 
    k = ceil(ix / (a * b)); 
    if k > c, k = c; end
    
end