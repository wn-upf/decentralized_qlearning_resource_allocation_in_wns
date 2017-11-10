% Decentralized_Qlearning_Resource_Allocation_in_WNs

%   Francesc Wilhelmi, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Boris Bellalta, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Cristina Cano, Wireless Networks Research Group (WINE-UOC), Universitat Oberta de Catalunya (UOC)
%   Anders Jonsson, Artificial Intelligence and Machine Learning Research Group (AIML-UPF), Universitat Pompeu Fabra (UPF)

function DrawNetwork3D(wlan)
% DrawNetwork3D - Plots a 3D of the network 
%   INPUT: 
%       * wlan - contains information of each WLAN in the map. For instance,
%       wlan(1) corresponds to the first one, so that it has unique
%       parameters (x,y,z,BW,CCA,etc.)

    MaxX=10;
    MaxY=5; 
    MaxZ=10;
    for j=1:size(wlan,2)
        x(j)=wlan(j).x;
        y(j)=wlan(j).y;
        z(j)=wlan(j).z;
    end
    figure
    axes;
    set(gca,'fontsize',16);
    labels = num2str((1:size(y' ))','%d');    
    for i=1:size(wlan,2)
        scatter3(wlan(i).x, wlan(i).y, wlan(i).z, 70, [0 0 0], 'filled');
        hold on;   
        scatter3(wlan(i).xn, wlan(i).yn, wlan(i).zn, 30, [0 0 1], 'filled');
        line([wlan(i).x, wlan(i).xn], [wlan(i).y, wlan(i).yn], [wlan(i).z, wlan(i).zn], 'Color', [0.4, 0.4, 1.0], 'LineStyle', ':');        
    end
    text(x,y,z,labels,'horizontal','left','vertical','bottom') 
    xlabel('x [meters]','fontsize',14);
    ylabel('y [meters]','fontsize',14);
    zlabel('z [meters]','fontsize',14);
    axis([0 MaxX 0 MaxY 0 MaxZ])
end