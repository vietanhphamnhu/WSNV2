clear all;
close all;
clc;DEAD


% figure(1);

load('mazumdar.mat');
S(n+1).yd = 0;
figure(1);
DEAD = 0;
Rmax = 20
for r=1:1:4000
    r
    figure(1);
    hold on;
    
    dead = 0;
    for i=1:1:n
        %checking if there is a dead node
        if (S(i).RE<=0)
%             plot(S(i).xd,S(i).yd,'red D');
            S(i).RE = 0;
            dead=dead+1;
            S(i).state='DEAD';
            S(i).type = 'DEAD';
            S(i).number_worker = 0;
%             hold on;
        else
            S(i).type='N';
            S(i).state='Initial_State';
            S(i).number_worker = 0;
%             plot(S(i).xd,S(i).yd,'o');
%             hold on;
        end
    end
%     plot(S(n+1).xd,S(n+1).yd,'x');
%     text(S(n+1).xd,S(n+1).yd,'  BS','Color','b','FontWeight','b');
    DEAD(r)=dead;
    for i= 1:1:n
        if S(i).RE > 0
            S(i).distoBS = norm([S(i).xd-50 S(i).yd]);
            number_neighbor_i = 0;
            sigma_neigh_cost = 0;
            for j= 1:1:n
                disJToI = norm([S(i).xd-S(j).xd S(i).yd-S(j).yd]);
                if (disJToI <= Rmax && disJToI > 0)
                    number_neighbor_i = number_neighbor_i + 1;
                    sigma_neigh_cost = sigma_neigh_cost + disJToI^2;
                end
            end
            S(i).neigh_des  = number_neighbor_i/n;%HERE
            S(i).neigh_cost = (sqrt(sigma_neigh_cost/number_neighbor_i))/Rmax;%HERE
        end
    end
    
    %  Tinh Fuzzy va Td %
    for i= 1:1:n
        if (S(i).RE >0)
            % compute Td 
            Energy_level = S(i).RE/S(i).Initial_energy;
            S(i).Fuzzy_fitness1 = evalfis([Energy_level S(i).distoBS], fis1);
            S(i).Fuzzy_fitness2 = evalfis([S(i).neigh_des S(i).neigh_cost], fis2);
            alpha = rand(1,1)/10 + 0.9;
            S(i).Td = alpha * (1 - S(i).Fuzzy_fitness1) * Tc;       
            S(i).candidate = [];
%             plot(S(i).xd,S(i).yd,'o');
%             hold on;
        end
    end
    % Start bau CH
    % Sap xep S(i) theo chieu tang dan cua Td %

    [x,idx] = sort([S.Td]);
    S = S(idx);
    for i=1:1:n
        if S(i).RE > 0
          if S(i).type == 'W'
              continue;
          else
              S(i).rad = evalfis([S(i).Fuzzy_fitness1 S(i).Fuzzy_fitness2],fis3);
              S(i).type = 'CH';
%               plot(S(i).xd,S(i).yd,'k*');
              for t=1:1:n
                distance = norm([S(i).xd-S(t).xd S(i).yd-S(t).yd]);
                if distance <= S(i).rad && distance > 0 && (S(i).RE>0)
                    k = length(S(t).candidate) + 1;
                    S(t).candidate(k) = S(i).id;
                    S(t).type = 'W';
                end
              end
          end
        end
    end
    %Remember to sort S
    % Should check again
    [x,idx] = sort([S.id]);
    S = S(idx);
    for i=1:1:n
      if isequal(S(i).type,'W') && (S(i).RE >0) && ~isempty(S(i).candidate)
        CH_cost = 0;
        for t=1:1:length(S(i).candidate)
            distoCH = norm([S(i).xd-S(S(i).candidate(t)).xd S(i).yd-S(S(i).candidate(t)).yd]);
            CH_cost(t) = distoCH * S(S(i).candidate(t)).distoBS/S(S(i).candidate(t)).RE;
        end
        k = find(CH_cost==min(CH_cost));
        S(i).candidate = S(i).candidate(k);
      end
    end
    for i=1:1:n
        if isequal(S(i).type, 'CH') && S(i).RE >0
            x = [S.candidate];
            tf1 = x == S(i).id;
            S(i).number_worker = sum(tf1==1);
        end
    end
    % End check
    %----End Cluster----
    
    %----Begin Routing-----
    % countCH = 0;
    S(n+1).xd = 50;
    S(n+1).yd = 0;
    CH_number = S(strcmp({S.type},'CH'));
    %Hoanh do cua CH
    x_CH = [CH_number.xd,S(n+1).xd]';
    %Tung do cua CH
    y_CH = [CH_number.yd,S(n+1).yd]';
    %id cua CH (sap xep theo so thu tu cua ma tran input cua code)
    id_CH = [CH_number.id, 101]';
    %Trong nay chua toan bo diem CH va diem sink ben duoi cung
    All_CH = [id_CH x_CH y_CH];
    %Khai bao so luong cua cac node ket noi trong network
    num_nodes = length(All_CH);
    num_segs=0;
    
    segments = zeros(length(All_CH)*(length(All_CH)-1)/2,3);
    for a = 1:length(All_CH)-1 % create edges between some of the nodes
%         text(All_CH(a,2),All_CH(a,3),[' ' num2str(id_CH(a))],'Color','b','FontWeight','b')
        for b = a+1:length(All_CH)
            d = sqrt(sum((All_CH(a,2:3) - All_CH(b,2:3)).^2));
            if (d <= Rmax)
                %plot([All_CH(a,2) All_CH(b,2)],[All_CH(a,3) All_CH(b,3)],'k.-')
                % add this link to the segments list
                num_segs = num_segs + 1;
                segments(num_segs,:) = [num_segs All_CH(a,1) All_CH(b,1)];
            end

        end
    end
    %Like a routing table
    segments(num_segs+1:num_nodes * (num_nodes-1)/2,:) = [];
    %------End Routing--------
    
    %Reduce energy
    for i=1:1:n
         if isequal(S(i).type,'W') && (S(i).RE >0)
                 CH = S(i).candidate;
                 disToCH = sqrt((S(i).xd-S(CH).xd)^2 + (S(i).yd-S(CH).yd)^2 );
                 if distoCH < d0 
                    S(i).RE = S(i).RE - bit*(ETX + Efs*(distoCH*distoCH));
                 end
                 if distoCH >= d0
                     S(i).RE = S(i).RE - bit*(ETX + Emp*(distoCH^4));
                 end
         end
         if (isequal(S(i).type,'CH')) && (S(i).RE > 0)
%               Nang luong nhan cua CH
%                  S(i).RE = S(i).RE - S(i).number_worker*bit*ETX;
                 [distance, path] = dijkstra(All_CH, segments, S(i).id, 101);
%                  path = Greedy(All_CH,S(i).id,60,Rmax);
%               Tinh nang luong truyen cua CH
                 if isnan(path)
                     if S(i).distoBS < d0
                        S(i).RE = S(i).RE - S(i).number_worker*bit*(ETX + Efs * (S(i).distoBS^2));
                     end
                     if S(i).distoBS >= d0
                        S(i).RE = S(i).RE - S(i).number_worker*bit*(ETX + Emp * (S(i).distoBS^4));
                     end
                 else
                     for q = 1:1:length(path)-1
                         distance_path = norm([S(path(q)).xd-S(path(q+1)).xd S(path(q)).yd-S(path(q+1)).yd]);
%                          S(path(q+1)).RE = S(path(q+1)).RE - (ETX + Efs*(distance_path^2) + ETX)*S(path(q)).number_worker*bit*10^-1;
                        if distance_path < d0
                         S(path(q)).RE = S(path(q)).RE - S(path(q)).number_worker*bit*(ETX + Efs * (distance_path^2));
                        end
                        if distance_path >= d0
                            S(path(q)).RE = S(path(q)).RE - S(path(q)).number_worker*bit*(ETX + Emp * (distance_path^4));                            
                        end
                     end
                 end
         end
    end
    [S.RE]
end
