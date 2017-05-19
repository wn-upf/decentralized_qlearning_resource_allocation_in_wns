% Decentralized_Qlearning_Resource_Allocation_in_WNs

%   Francesc Wilhelmi, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Boris Bellalta, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Cristina Cano, Wireless Networks Research Group (WINE-UOC), Universitat Oberta de Catalunya (UOC)
%   Anders Jonsson, Artificial Intelligence and Machine Learning Research Group (AIML-UPF), Universitat Pompeu Fabra (UPF)

function selected_action = selectActionQLearning(Qval, actions_ch, actions_cca, actions_tpc, e)
% selectActionQLearning: returns the best possible action given the current state
%   OUTPUT:
%        * selected_action - contains the selected channel, CCA and TPC
%   INPUT:
%       * Qval - Q-values matrix for a given agent (maps actions with rewards)
%       * actions_ch - set of channels available
%       * actions_cca - set of CCA values available
%       * actions_tpc - set of TPC values available
%       * e - epsilon-greedy approach for exploration

    indexes=[];
    
    % Exploration approach
    %rand('twister',sum(100*clock))

    if rand()>e 
        
        [val,~] = max(max(Qval));
        
        % Check if there is more than one occurrence in order to select a value randomly
        if sum(Qval(:)==val)>1
            for i=1:size(Qval,2)
                if Qval(i) == val, indexes = [indexes i]; end
            end
            if isempty(indexes)
                [~,index] = max(max(Qval));
            else
                index = randsample(indexes,1);
            end
            
        else
            [~,index] = max(Qval);
        end
        
    else
        index = randi([1 size(Qval,2)], 1, 1);
    end
    
    [a,b,c] = val2indexes(index, size(actions_ch,2), size(actions_cca,2), size(actions_tpc,2));
    selected_action = [a b c];
    
end