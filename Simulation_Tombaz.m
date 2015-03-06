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
r=0:0.001:4.5;                        %avrerage data rate reaquirement per active user [MBps]
P_macro = Ns*(a_M*P_tx_macro+b_M);    %The power consumption of the macro BS
P_femto =a_F*P_tx_femto+b_F;          %The power consumption of the macro BS
A_g_tot=r.*A;                         %the total aggregate trafic collected at the fiber switch
U_max=10;                             %The maximum transmission rate of an uplink interface
C_MW=36;                              %the maximum capacity of the switch
N_active_macro=C_macro./r;            %The number of active users
n_Dslam_ports= 16;                    % number of ports of the Dslam
n_F_ports= 24;                        % number of ports of the fiber switch
P_modem= 5;                           % modem power consumption
P_Dslam=85;                           % Dslam power consumption
P_SFP= 1;                             % small form-factor pluggable transceivers power consumption
P_s=300;                              % power consomption of fiber switch
P_SFP_=1;                             % power consomption of SFP+         
P_lowc=37;                            % the low power consumption region of the microwave antennas
P_highc=92.5;                         % the high power consumption region of the microwave antennas 
P_GES_max= 50;                        % power consomption of Gigabit ethernet switch
n_GES=12;                             %number of port in GES
n_MW=50;                              % the max number of microwave links a hub can support
P_MW=53;                              % power consumption of switch inside the hub
P_ONU=5;                              % power consmuption of ONU
N_port_split=32;                      %number of ports of

%Architecture microwave only
figure 

for mu=0:0.2:0.6
    if mu==0
        N_macro=(ro*A*alpha_max)./N_active_macro; 
        N_hub=(N_macro)./n_MW; 
        N_ul=A_g_tot/U_max;
        N_MW=A_g_tot/C_MW;
        P_arch2=N_macro*P_lowc+N_hub*P_highc +N_ul*P_SFP_+N_MW*P_MW;
        P2=(P_arch2+N_macro*P_macro)/A;
        plot(r,P2)
        hold on
    else
        N_femto = N_a*mu;
        P_GES=(N_femto.*P_GES_max)./(N_b*n_GES);
        N_macro=(ro*A*(1-mu)*alpha_max)./N_active_macro; 
        N_Dslam= N_femto./n_Dslam_ports;  
        N_s= (N_Dslam+N_macro)./n_F_ports;
        N_hub=(N_b+N_macro)./n_MW; 
        N_ul=max(N_hub,A_g_tot/U_max);
        N_MW=N_hub;
        P_arch2=(N_b+N_macro)*P_lowc+N_b*P_GES+N_hub*P_highc +N_ul*P_SFP_+N_MW*P_MW;
        P2=(N_femto*P_femto+N_macro*P_macro+P_arch2)/A;
        plot(r,P2)
        hold on
    end
end

%Architecture FTTB+Microwave
figure 
for mu=0:0.2:0.6
         if mu==0
            N_macro=(ro*A*alpha_max)./N_active_macro; 
            N_hub=(N_macro)./n_MW; 
            N_MW=max(N_hub,A_g_tot/C_MW);
            N_ul=max(N_hub,A_g_tot/U_max);
            P_arch3= N_macro*P_lowc+N_hub*(P_highc+P_SFP_)+N_MW*P_MW+N_ul*P_SFP_; 
            P3=(P_arch3+N_macro*P_macro)/A;
            plot(r,P3)
            hold on
         else
            N_femto = N_a*mu;
            P_GES=(N_femto.*P_GES_max)./(N_b*n_GES);
            N_macro=(ro*A*(1-mu)*alpha_max)./N_active_macro; 
            N_Dslam= N_femto./n_Dslam_ports;  
            N_s= N_b./n_F_ports; 
            N_hub=(N_macro)./n_MW; 
            N_ul=max(N_hub+N_s,A_g_tot/U_max);
            N_MW=N_hub;
            P_arch3= N_b*(P_GES+2*P_SFP)+N_macro*P_lowc+N_s*P_s+N_hub*(P_highc+P_SFP_)+N_MW*P_MW+N_ul*P_SFP_; 
            P3=(N_femto*P_femto+N_macro*P_macro+P_arch3)/A;
            plot(r,P3)
            hold on
         end
end

%Architecture FTTB+10GPON
figure 
for mu=0:0.2:0.6
    if mu==0
        N_macro=(ro*A*alpha_max)./N_active_macro; 
        N_split=floor((N_b+N_macro)/N_port_split)+1;                        %nombre de splitter   
        N_s= floor((N_split)/n_F_ports)+1;
        N_ul=max(N_s,A_g_tot/U_max);
        P_arch4= N_s*P_s+N_ul*P_SFP_+2*N_macro*P_SFP; 
        P4=(N_macro*P_macro+P_arch4)/A;
        plot(r,P4)
        hold on
    else
        N_femto = N_a*mu;
        P_GES=(N_femto.*P_GES_max)./(N_b*n_GES);
        N_macro=(ro*A*(1-mu)*alpha_max)./N_active_macro; 
        N_split=floor((N_b+N_macro)/N_port_split)+1;                        %nombre de splitter   
        N_s= floor(N_split/n_F_ports)+1; 
        N_ul=max(N_s,A_g_tot/U_max);
        P_arch5= N_b*(P_GES+2*P_SFP+P_ONU)+N_s*P_s+N_ul*P_SFP_+N_macro*(2*P_SFP+P_ONU); 
        P5=(N_femto*P_femto+N_macro*P_macro+P_arch5)/A;
        plot(r,P5)
        hold on
    end
end

