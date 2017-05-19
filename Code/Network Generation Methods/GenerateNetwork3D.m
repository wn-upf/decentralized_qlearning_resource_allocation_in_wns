% Decentralized_Qlearning_Resource_Allocation_in_WNs

%   Francesc Wilhelmi, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Boris Bellalta, Wireless Networking Research Group (WN-UPF), Universitat Pompeu Fabra
%   Cristina Cano, Wireless Networks Research Group (WINE-UOC), Universitat Oberta de Catalunya (UOC)
%   Anders Jonsson, Artificial Intelligence and Machine Learning Research Group (AIML-UPF), Universitat Pompeu Fabra (UPF)

function wlan = GenerateNetwork3D(N_WLANs, NumChannels, topology, stas_position, printMap)
% GenerateNetwork3D - Generates a 3D network 
%   OUTPUT: 
%       * wlan - contains information of each WLAN in the map. For instance,
%       wlan(1) corresponds to the first one, so that it has unique
%       parameters (x,y,z,BW,CCA,etc.)
%   INPUT: 
%       * N_WLANs: number of WLANs on the studied environment
%       * NumChannels: number of available channels
%       * topology: topology of the network ('ring', 'line' or 'grid')
%       * stas_position: way STAs are placed (1 - "random", 2 - "safe" or 3 - "exposed")
%       * printMap: flag for calling DrawNetwork3D at the end


    actions_tpc = [5 10 15 20];
    actions_cca = [-82];

    % Dimensions of the 3D map
    MaxX=10;
    MaxY=5; 
    MaxZ=10;
    % Maximum range for a STA
    MaxRangeX = 1;
    MaxRangeY = 1;
    MaxRangeZ = 1;
    MaxRange = sqrt(3);
    % AP density
%     disp('Density of APs');
%     disp(N_WLANs/(MaxX*MaxY*MaxZ));
    
    if (topology == 'ring')
        x0 = MaxX/2;
        y0 = MaxY/2;
        r = (MaxY-1)/2;
        n=N_WLANs;
        tet=linspace(-pi,pi,n+1);                
        posX = r*cos(tet)+x0;
        posY = r*sin(tet)+y0;
    end
    
    gridPositions4 = [
    (MaxX)/N_WLANs (MaxY)/N_WLANs MaxZ/2;
    (MaxX)/N_WLANs 3*(MaxY)/N_WLANs MaxZ/2;
    3*(MaxX)/N_WLANs (MaxY)/N_WLANs MaxZ/2;
    3*(MaxX)/N_WLANs 3*(MaxY)/N_WLANs MaxZ/2;
    ];
             
    gridPositions8 = [
    (MaxX)/(N_WLANs/2) (MaxY)/(N_WLANs/2) MaxZ/(N_WLANs/2);
    (MaxX)/(N_WLANs/2) 3*(MaxY)/(N_WLANs/2) MaxZ/(N_WLANs/2);
    3*(MaxX)/(N_WLANs/2) (MaxY)/(N_WLANs/2) MaxZ/(N_WLANs/2);
    3*(MaxX)/(N_WLANs/2) 3*(MaxY)/(N_WLANs/2) MaxZ/(N_WLANs/2);
    (MaxX)/(N_WLANs/2) (MaxY)/(N_WLANs/2) 3*MaxZ/(N_WLANs/2);
    (MaxX)/(N_WLANs/2) 3*(MaxY)/(N_WLANs/2) 3*MaxZ/(N_WLANs/2);
    3*(MaxX)/(N_WLANs/2) (MaxY)/(N_WLANs/2) 3*MaxZ/(N_WLANs/2);
    3*(MaxX)/(N_WLANs/2) 3*(MaxY)/(N_WLANs/2) 3*MaxZ/(N_WLANs/2);
    ];
  
    gridPositions12 = [
    (MaxX)/(N_WLANs/3) (MaxY)/(N_WLANs/3) MaxZ/(N_WLANs/3);
    (MaxX)/(N_WLANs/3) 3*(MaxY)/(N_WLANs/3) MaxZ/(N_WLANs/3);
    3*(MaxX)/(N_WLANs/3) (MaxY)/(N_WLANs/3) MaxZ/(N_WLANs/3);
    3*(MaxX)/(N_WLANs/3) 3*(MaxY)/(N_WLANs/3) MaxZ/(N_WLANs/3);
    (MaxX)/(N_WLANs/3) (MaxY)/(N_WLANs/3) 2*MaxZ/(N_WLANs/3);
    (MaxX)/(N_WLANs/3) 3*(MaxY)/(N_WLANs/3) 2*MaxZ/(N_WLANs/3);
    3*(MaxX)/(N_WLANs/3) (MaxY)/(N_WLANs/3) 2*MaxZ/(N_WLANs/3);
    3*(MaxX)/(N_WLANs/3) 3*(MaxY)/(N_WLANs/3) 2*MaxZ/(N_WLANs/3);
    (MaxX)/(N_WLANs/3) (MaxY)/(N_WLANs/3) 3*MaxZ/(N_WLANs/3);
    (MaxX)/(N_WLANs/3) 3*(MaxY)/(N_WLANs/3) 3*MaxZ/(N_WLANs/3);
    3*(MaxX)/(N_WLANs/3) (MaxY)/(N_WLANs/3) 3*MaxZ/(N_WLANs/3);
    3*(MaxX)/(N_WLANs/3) 3*(MaxY)/(N_WLANs/3) 3*MaxZ/(N_WLANs/3);
    ];
    
    for j=1:N_WLANs 
        wlan(j).PTdBm = datasample(actions_tpc,1); % Assign Tx Power
        wlan(j).CCA = datasample(actions_cca,1);  % Assign CCA
        wlan(j).channel = round((NumChannels-1).*rand() + 1);% mod(j,NumChannels/2) + 1;   % Assign channels
        wlan(j).BW = 20e6; 
        if (topology == 'ring')
            wlan(j).x = posX(j);
            wlan(j).y = posY(j);
            wlan(j).z = MaxZ/2; 
        elseif (topology == 'line')
            wlan(j).x = j*((MaxX-2)/N_WLANs);
            wlan(j).y = MaxY/2;
            wlan(j).z = MaxZ/2; 
        elseif (topology == 'grid') 
            if(N_WLANs == 4)
                wlan(j).x = gridPositions4(j,1);
                wlan(j).y = gridPositions4(j,2);
                wlan(j).z = gridPositions4(j,3); 
            elseif(N_WLANs == 8)
                wlan(j).x = gridPositions8(j,1);
                wlan(j).y = gridPositions8(j,2);
                wlan(j).z = gridPositions8(j,3); 
            elseif(N_WLANs == 12)
                wlan(j).x = gridPositions12(j,1);
                wlan(j).y = gridPositions12(j,2);
                wlan(j).z = gridPositions12(j,3);  
            else
                disp('error, only 4, 8 and 12 WLANs allowed')
            end

        end
        % Build arrays of locations for each AP
        x(j)=wlan(j).x;
        y(j)=wlan(j).y;
        z(j)=wlan(j).z;   
        
        switch topology
            
            case 'grid'
                % Add the listening STA to each AP randomly
                if stas_position == 1 % RANDOM
                    if(rand() < 0.5) 
                        wlan(j).xn = wlan(j).x + MaxRangeX.*rand();
                    else 
                        wlan(j).xn = wlan(j).x - MaxRangeX.*rand();
                    end

                    if(rand() < 0.5) 
                        wlan(j).yn = wlan(j).y + MaxRangeY.*rand();
                    else 
                        wlan(j).yn = wlan(j).y - MaxRangeY.*rand();
                    end

                    if(rand() < 0.5) 
                        wlan(j).zn = wlan(j).z + MaxRangeZ.*rand();
                    else 
                        wlan(j).zn = wlan(j).z - MaxRangeZ.*rand();
                    end
                elseif stas_position == 2 % SAFE
                    if j == 1
                        wlan(j).xn = wlan(j).x - MaxRangeX;
                        wlan(j).yn = wlan(j).y - MaxRangeY;
                    elseif j == 2
                        wlan(j).xn = wlan(j).x - MaxRangeX;
                        wlan(j).yn = wlan(j).y + MaxRangeY;
                    elseif j == 3
                        wlan(j).xn = wlan(j).x + MaxRangeX;
                        wlan(j).yn = wlan(j).y - MaxRangeY;
                    elseif j == 4
                        wlan(j).xn = wlan(j).x + MaxRangeX;
                        wlan(j).yn = wlan(j).y + MaxRangeY;
                    end
                     wlan(j).zn = wlan(j).z;  
                elseif stas_position == 3 % EXPOSED
                    if j == 1
                        wlan(j).xn = wlan(j).x + MaxRangeX;
                        wlan(j).yn = wlan(j).y + MaxRangeY;
                    elseif j == 2
                        wlan(j).xn = wlan(j).x + MaxRangeX;
                        wlan(j).yn = wlan(j).y - MaxRangeY;
                    elseif j == 3
                        wlan(j).xn = wlan(j).x - MaxRangeX;
                        wlan(j).yn = wlan(j).y + MaxRangeY;
                    elseif j == 4
                        wlan(j).xn = wlan(j).x - MaxRangeX;
                        wlan(j).yn = wlan(j).y - MaxRangeY;
                    end
                     wlan(j).zn = wlan(j).z;                         
                end
                
            case 'line'
                % Add the listening STA to each AP randomly
                if stas_position == 1 % RANDOM
                    if(rand() < 0.5) 
                        wlan(j).xn = wlan(j).x + MaxRangeX.*rand();
                    else 
                        wlan(j).xn = wlan(j).x - MaxRangeX.*rand();
                    end

                    if(rand() < 0.5) 
                        wlan(j).yn = wlan(j).y + MaxRangeY.*rand();
                    else 
                        wlan(j).yn = wlan(j).y - MaxRangeY.*rand();
                    end

                    if(rand() < 0.5) 
                        wlan(j).zn = wlan(j).z + MaxRangeZ.*rand();
                    else 
                        wlan(j).zn = wlan(j).z - MaxRangeZ.*rand();
                    end
                elseif stas_position == 2 % SAFE
                    wlan(j).xn = wlan(j).x;
                    wlan(j).yn = wlan(j).y + MaxRangeY;
                    wlan(j).zn = wlan(j).z;
                elseif stas_position == 3 % EXPOSED
                    wlan(j).xn = wlan(j).x + ((MaxX-2)/N_WLANs)/2;
                    wlan(j).yn = wlan(j).y;
                    wlan(j).zn = wlan(j).z;                    
                end
                
            case 'ring'
                               % Add the listening STA to each AP randomly
                if stas_position == 1 % RANDOM
                    if(rand() < 0.5) 
                        wlan(j).xn = wlan(j).x + MaxRangeX.*rand();
                    else 
                        wlan(j).xn = wlan(j).x - MaxRangeX.*rand();
                    end

                    if(rand() < 0.5) 
                        wlan(j).yn = wlan(j).y + MaxRangeY.*rand();
                    else 
                        wlan(j).yn = wlan(j).y - MaxRangeY.*rand();
                    end

                    if(rand() < 0.5) 
                        wlan(j).zn = wlan(j).z + MaxRangeZ.*rand();
                    else 
                        wlan(j).zn = wlan(j).z - MaxRangeZ.*rand();
                    end
                elseif stas_position == 2 % SAFE
                    wlan(j).xn = wlan(j).x;
                    wlan(j).yn = wlan(j).y;
                    wlan(j).zn = wlan(j).z - MaxRangeZ;  
                elseif stas_position == 3 % EXPOSED
                    if j == 1
                        wlan(j).xn = wlan(j).x + MaxRangeX;
                        wlan(j).yn = wlan(j).y + MaxRangeY;
                    elseif j == 2
                        wlan(j).xn = wlan(j).x + MaxRangeX;
                        wlan(j).yn = wlan(j).y - MaxRangeY;
                    elseif j == 3
                        wlan(j).xn = wlan(j).x - MaxRangeX;
                        wlan(j).yn = wlan(j).y + MaxRangeY;
                    elseif j == 4
                        wlan(j).xn = wlan(j).x - MaxRangeX;
                        wlan(j).yn = wlan(j).y - MaxRangeY;
                    end
                     wlan(j).zn = wlan(j).z;                         
                end
        end
        xn(j)=wlan(j).xn; %what is xn(j) B: the "x" position of node j
        yn(j)=wlan(j).yn;
        zn(j)=wlan(j).zn;
        
    end
%     disp('Channels selected per WLAN')
%     for i=1:N_WLANs
%         channels(i) = wlan(i).channel;       
%     end
%     for i=1:NumChannels
%         sumChannels(i) = sum(channels==i);
%     end
%     disp(channels)
%     disp('Times a channel is occupied')
%     disp(sumChannels)
    
%     for i=1:N_WLANs
%         wlan(i)
%     end
   
    %% Plot map of APs and STAs
   if printMap == 1
        DrawNetwork3D(wlan);
   end