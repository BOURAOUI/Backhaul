close all
N_b=10000;                            % number of building
Ns=3;                                 %The number of sectors 3 or 1
a_M=4.7;                              %The portion of the power consumption for macro BS
b_M=130;                              %The power consumption of the active site cooling and the signa processing for macro BS
a_F=8;                                %The portion of the power consumption for femto BS
b_F=4.8;                              %The power consumption of the active site cooling and the signa processing for femto BS
P_tx_macro=6.8;                       %power fed of the antenna of the macro BS
P_tx_femto=0.2;                       %power fed of the antenna of the femto BS
ro=3000;                              %population density per Km*Km
alpha_max=0.16;                       %16% of the subscribers are active during the busy hour
A=10*10;                              %The covered area
N_a=N_b*10;                           %number of appartement
C_macro=75;                           %The average macro BS
r=0:0.01:4.5;                        %avrerage data rate reaquirement per active user
Price_femto =200;                     %The price of the femto BS
A_g_tot=r.*A;                         %the total aggregate trafic collected at the fiber switch
U_max=10;                             %The maximum transmission rate of an uplink interface
C_MW=36;                              %the maximum capacity of the switch
N_active_macro=C_macro./r;            %The number of active users
n_Dslam_ports= 16;                    % number of ports of the Dslam
n_F_ports= 24;                        % number of ports of the fiber switch
Price_modem= 166;                     % modem price
Price_Dslam=924;                     % Dslam price
Price_SFP= 357.9;                    % small form-factor pluggable transceivers price
Price_s=3568;                         % price of fiber switch
Price_SFP_=357.9;                    % price of SFP+         
Price_antenna_macro=2000;             % price of antenna in macro BS
Price_Hub=50000;                      % price of Hub and installation 
Price_GES= 1800;                      % price of Gigabit ethernet switch
n_GES=12;                             %number of port in GES
n_MW=20;                              % the max number of microwave links a hub can support
Price_spec=150;                       %Yearly spectrum leasing per link
Price_fibre=44000;                    %deploiement of the fibre optique 
Price_fibre_supp_arch4=100;           %cost of fibre between BS and splitter
Price_splitter=340;                   %Price splitter
N_port_split=32;                      %number port of the splitter
Price_ONU=105;                        %Price of the ONU
Price_OLT=1750;                       %Price of the OLT

%Architecture Microwave only
% figure 
% 
% for mu=0:0.2:0.6
%     if mu==0
%         N_macro=(ro*A*alpha_max)./N_active_macro; 
%         N_hub=(N_macro)./n_MW; 
%         N_ul=A_g_tot/U_max;
%         N_MW=A_g_tot/C_MW;
%         P_arch2=N_macro*(Price_antenna_macro)+N_hub*Price_Hub +N_ul*Price_SFP_;
%         P2=(P_arch2+N_macro*(Price_antenna_macro))/A;
%         plot(r,P2)
%         hold on
%     else
%         N_femto = N_a*mu;
%         P_GES=(N_femto.*Price_GES)./(N_b*n_GES);
%         N_macro=(ro*A*(1-mu)*alpha_max)./N_active_macro; 
%         N_Dslam= N_femto./n_Dslam_ports;  
%         N_s= (N_Dslam+N_macro)./n_F_ports;
%         N_hub=(N_b+N_macro)./n_MW; 
%         N_ul=max(N_hub,A_g_tot/U_max);
%         N_MW=N_hub;
%         P_arch2=(N_b+N_macro)*Price_antenna_macro+N_b*Price_GES+N_hub*Price_Hub+N_ul*Price_SFP_;
%         P2=(N_femto*Price_femto+N_macro*Price_antenna_macro+P_arch2)/A;
%         plot(r,P2)
%         hold on
%     end
% end

%Architecture FTTB+Microwave
figure 
for mu=0:0.2:0.6
         if mu==0
            N_macro=(ro*A*alpha_max)./N_active_macro; 
            N_hub=(N_macro)./n_MW; 
            N_MW=max(N_hub,A_g_tot/C_MW);
            N_ul=max(N_hub,A_g_tot/U_max);
            P_arch3= N_macro*(Price_antenna_macro+Price_spec)+N_hub*(Price_Hub)+N_ul*Price_SFP_; 
            P3=(P_arch3+Price_fibre)/A;
            plot(r,P3)
            hold on
         else
            N_femto = N_a*mu;
            P_GES=(N_femto.*Price_GES)./(N_b*n_GES);
            N_macro=(ro*A*(1-mu)*alpha_max)./N_active_macro; 
            N_Dslam= N_femto./n_Dslam_ports;  
            N_s= N_b./n_F_ports; 
            N_hub=(N_macro)/n_MW;
            
            N_ul=max(N_hub+N_s,A_g_tot/U_max);
            P_arch3= N_b*(Price_GES+2*Price_SFP)+N_macro*(Price_antenna_macro+Price_spec)+N_s*Price_s+N_hub*(Price_Hub)+N_ul*Price_SFP_; 
            P3=(P_arch3+Price_fibre)/A;
            plot(r,P3)
            hold on
         end
end

%Architecture FTTB+10GPON
figure 
for mu=0:0.2:0.6
    if mu==0
        N_macro=(ro*A*alpha_max)./N_active_macro; 
        N_split=floor((N_b+N_macro)./N_port_split)+1;                        %nombre de splitter   
        N_s= floor((N_split)/n_F_ports)+1;
        N_ul=max(N_s,A_g_tot/U_max);
        P_arch4= N_s*Price_s+N_ul*Price_SFP_+N_macro*(4*Price_SFP+Price_fibre_supp_arch4+Price_ONU)+N_split*(Price_splitter+Price_OLT); 
        P4=(P_arch4+Price_fibre)/A;
        plot(r,P4)
        hold on
    else
        N_femto = N_a*mu;
        N_macro=(ro*A*(1-mu)*alpha_max)./N_active_macro; 
        N_split=floor((N_b+N_macro)./N_port_split)+1;                        %nombre de splitter   
        N_s= floor(N_split/n_F_ports)+1; 
        N_ul=max(N_s,A_g_tot/U_max);
        P_arch4= N_b*(2*Price_SFP+Price_GES+Price_ONU)+N_s*Price_s+N_ul*Price_SFP_+N_macro*(4*Price_SFP+Price_ONU+Price_fibre_supp_arch4)+N_split*(Price_splitter+Price_OLT); 
        P5=(P_arch4+Price_fibre)/A;
        plot(r,P5)
        hold on
    end
end
