clear all; clc
close all;

addpath(pwd)
addpath(genpath([pwd,'/OpenMLC-Matlab-2'])); % OpenMLC classes and functions
addpath(genpath([pwd,'/MLC_Problemfunctions'])); % functions related to the turbine problem
addpath(genpath([pwd,'/ParforProgMon'])); % Parfor progress monitor


load('BestandBLSimout.mat')
load('20201203_062004mlc_ae')
ChannelNames = SimOut{1,1}.ChanName;

%% Get Output stats for Best individual and baseline,
if false
   FastPath = 'C:\Users\James\Documents\GitHub\ATLAS_FAST-par';
   MLCPath = 'C:\Users\James\Documents\GitHub\ATLAS_Offshore';
   BestAndBaseline = {'Thetaout = [0;0;0]; X0 = [0; 0; 0]; Xdot = [0; 0; 0]; u = [OutData; X]; y = [	((sin((cos((((sin(tanh(u(34))) + u(24)) + u(24)) - tanh((my_div(2.932,(my_div(u(113),(sin(sin(tanh(u(34)))) - u(107))))))))) + (sin(my_log((-0.731))) + u(24)))) + u(24)) + u(34));  		((sin(cos((tanh(u(34)) - tanh((my_div((-1.475),(-1.233))))))) + u(24)) * (3.824 + 8.627));  		u(34);  		my_log(sin(6.03));  		(8.254 + (-2.644));  		(-9.104)]; Thetaout(1) = y(1); Thetaout(2) = y(2); Thetaout(3) = y(3); Xdot(1) = y(4); Xdot(2) = y(5); Xdot(3) = y(6); ', 'Thetaout = [0;0;0]; X0 = [0; 0; 0]; Xdot = [0; 0; 0]; u = [OutData; X]; y = [0; 0; 0; 0; 0; 0]; Thetaout(1) = y(1); Thetaout(2) = y(2); Thetaout(3) = y(3); Xdot(1) = y(4); Xdot(2) = y(5); Xdot(3) = y(6);' };
   BestAndBaselineJust2 = {'Thetaout = [0;0;0]; X0 = [0; 0; 0]; Xdot = [0; 0; 0]; u = [OutData; X]; y = [	(0);  		((sin(cos((tanh(u(34)) - tanh((my_div((-1.475),(-1.233))))))) + u(24)) * (3.824 + 8.627));  		0;  		my_log(sin(6.03));  		(8.254 + (-2.644));  		(-9.104)]; Thetaout(1) = y(1); Thetaout(2) = y(2); Thetaout(3) = y(3); Xdot(1) = y(4); Xdot(2) = y(5); Xdot(3) = y(6); ', 'Thetaout = [0;0;0]; X0 = [0; 0; 0]; Xdot = [0; 0; 0]; u = [OutData; X]; y = [0; 0; 0; 0; 0; 0]; Thetaout(1) = y(1); Thetaout(2) = y(2); Thetaout(3) = y(3); Xdot(1) = y(4); Xdot(2) = y(5); Xdot(3) = y(6);' };
   BestAndBaselineJust2NoNacelle = {'Thetaout = [0;0;0]; X0 = [0; 0; 0]; Xdot = [0; 0; 0]; u = [OutData; X]; y = [	(0);  		((sin(cos((tanh(u(34)) - tanh((my_div((-1.475),(-1.233)))))))) * (3.824 + 8.627));  		0;  		my_log(sin(6.03));  		(8.254 + (-2.644));  		(-9.104)]; Thetaout(1) = y(1); Thetaout(2) = y(2); Thetaout(3) = y(3); Xdot(1) = y(4); Xdot(2) = y(5); Xdot(3) = y(6); ', 'Thetaout = [0;0;0]; X0 = [0; 0; 0]; Xdot = [0; 0; 0]; u = [OutData; X]; y = [0; 0; 0; 0; 0; 0]; Thetaout(1) = y(1); Thetaout(2) = y(2); Thetaout(3) = y(3); Xdot(1) = y(4); Xdot(2) = y(5); Xdot(3) = y(6);' };
   [CF, SimOut, Costs, pMetrics] = MLC_PostEval(BestAndBaselineJust2NoNacelle, mlc.parameters, FastPath, MLCPath);
   save('BestandBLJ2NNSimout.mat','CF','SimOut','Costs','pMetrics')
end

%%plot Fast-Par Plots
plotTag = struct('Rel_FreqComp',             'plot', ...                    % Relative contribution by frequency and component                             
                 'Rel_Comp',                 'plot', ...                    % Relative contribution per component
                 'Abs_FreqComp',             'plot', ...                    % Absolute contribution by frequency and component
                 'Abs_Comp',                 'plot', ...                    % Absolute contribution per component
                 'Combine',                  'yes');                        % 'yes' will combine all controlers into one plot, 

fBuildPlotsMLCPost(CF(1), CF(2), pMetrics, plotTag, {'Best MLC Controler'})




%% Best controler Plaintext 

% y = [

% sin(cos((sin(tanh(PITCH)) + 2*NACELL) - tanh(my_div(2.932,(my_div(STATE3,(sin(sin(tanh(PITCH))) - NORMTIE2)))))) -0.136 + NACELL) + NACELL + PITCH;
% sin(cos(sin(tanh(PITCH)) + 2*NACELL) -0.136 + NACELL) + NACELL + PITCH;

% 12.45*(sin(cos((tanh(PITCH) - 0.832))) + NACELL);  		
% PITCH;


% -1.3843;
% 5.61;
% -9.104; 
% ]

%%

%Hard Code needed chanels now bewcause im lazy
Pnum = 34;
Nnum = 24;
Tnum = 107;

Cases = [1,6,7,8,10,12];
figure
sgtitle('Reductions In Platform Pitch Movement Vs. Baseline CPC Controller')
for iCase = [1:6]
    Case = Cases(iCase);
    
    PITCH = SimOut{Case,1}.Channels(:,Pnum);
    TIME = SimOut{Case,1}.Channels(:,1);
    BLPITCH = SimOut{Case,2}.Channels(:,Pnum);

    subplot(2,3,iCase);
    plot(TIME,BLPITCH,TIME,PITCH);
    ylabel('platform pitch (Deg)');
    xlabel('Time (s)');
    title(strcat('DLC',num2str(Case)));
       
end
legend('Baseline CPC','MLC Derrived IPC')




Case = 1;   
PITCH = SimOut{Case,1}.Channels(:,Pnum);
NACELLE = SimOut{Case,1}.Channels(:,Nnum);
TIE2 = SimOut{Case,1}.Channels(:,Tnum);
TIME = SimOut{Case,1}.Channels(:,1);
BLPITCH = SimOut{Case,2}.Channels(:,Pnum);
BLNACELL = SimOut{Case,2}.Channels(:,Nnum);

NORMPITCH = (PITCH - mlc.parameters.problem_variables.BaselineMean(Pnum)) ./ mlc.parameters.problem_variables.BaselineDetrendRMS(Pnum);
NORMNACELLE = (NACELLE - mlc.parameters.problem_variables.BaselineMean(Nnum)) ./ mlc.parameters.problem_variables.BaselineDetrendRMS(Nnum);
NORMTIE2 = (TIE2 - mlc.parameters.problem_variables.BaselineMean(Tnum)) ./ mlc.parameters.problem_variables.BaselineDetrendRMS(Tnum);
STATE3 = -9.104 * TIME;

%Simplified Blade 1
Y1 = sin(cos(sin(tanh(NORMPITCH)) + 2*NORMNACELLE) -0.136 + NORMNACELLE) + NORMNACELLE + NORMPITCH;
%Actual Blade 1
Y1a = sin(cos((sin(tanh(NORMPITCH)) + 2*NORMNACELLE) - tanh(my_div(2.932,(my_div(STATE3,(sin(sin(tanh(NORMPITCH))) - NORMTIE2)))))) -0.136 + NORMNACELLE) + NORMNACELLE + NORMPITCH;
%Blade 2
Y2 = 12.45*(sin(cos((tanh(NORMPITCH) - 0.832))) + NORMNACELLE);
%Blade 3
Y3 = NORMPITCH;

figure
title('Relationship Between Controler Input and Blade 1 Output')
subplot(1,2,1);
scatter(NORMPITCH,Y1,5,'filled','MarkerFaceAlpha',0.1,'MarkerEdgeAlpha',0.1)
xlabel('Platform Pitch (PtfmPitch)')
ylabel('Controler Output (Blade 1)')
subplot(1,2,2);
scatter(NORMNACELLE,Y1,5,'filled','MarkerFaceAlpha',0.1,'MarkerEdgeAlpha',0.1)
xlabel('Nacelle Acceleration (NcIMUTAxs)')
ylabel('Controler Output (Blade 1)')



figure
plot(TIME,NORMPITCH,TIME,NORMNACELLE,TIME,zeros(1,length(TIME)))



%% Big 3D plot

Range = [-3:0.25:3];
Surface1 = zeros(length(Range),length(Range));
Surface2 = Surface1;
Surface3 = Surface1;

XLines = 20;
YLines = 20;

Colortype = 'Same'  ;            %All 3 plots use same color map and scale 
%Colortype = 'Unique'   ;         %Each plot has a unique colormap

%DotCollor = 'r'  ;               %Red
DotCollor = 'colormap' ;        %Same color as corresponding collor map

%_________________________________________________________________________

XSpace = round(length(Range)/XLines);
YSpace = round(length(Range)/YLines);

%Mesh Values______________________________________________________________
for ii = 1:length(Range) 
    iPitch = Range(ii);
    for jj = 1:length(Range)
      iNacelle = Range(jj);
      Surface1(ii,jj) = sin(cos(sin(tanh(iPitch)) + 2*iNacelle) -0.136 + iNacelle) + iNacelle + iPitch;
      Surface2(ii,jj) = 12.45*(sin(cos((tanh(iPitch) - 0.832))) + iNacelle);
      Surface3(ii,jj) = iPitch;
   end
end

Surfaces{1} = Surface1;
Surfaces{2} = Surface2;
Surfaces{3} = Surface3;

%Colors___________________________________________________________________
ZRange = [-50,50];
CBits = 100;
CMap = colormap(parula(CBits));
colormap(parula(CBits))

if strcmp(Colortype,'Same')
    
    MeshMax = max([max(Surface3(:)),max(Surface2(:)),max(Surface1(:))]);
    MeshMin = min([min(Surface3(:)),min(Surface2(:)),min(Surface1(:))]);

    MeshMax = 50;
    MeshMin = -50;
    
    StepSize = (MeshMax - MeshMin)/length(CMap);
    Steps = [MeshMin:StepSize:MeshMax-StepSize]; %Min to Max - 1
    
    
    for hh = 1:3
        StepVals{hh} = Steps(Steps>=(min(Surfaces{hh}(:))-StepSize)&Steps<=max(Surfaces{hh}(:)));
        CMaps{hh} = CMap(Steps>=(min(Surfaces{hh}(:))-StepSize)&Steps<=max(Surfaces{hh}(:)),:);
        CMapIndex{hh} = 1:length(CMaps{hh});
        for ii = 1:length(Range)
            for jj = 1:length(Range)
                MeshVal = Surfaces{hh}(ii,jj);
                TIdx = max(CMapIndex{hh}(StepVals{hh}<=MeshVal));
                CMapsG{hh}(ii,jj,:) = CMaps{hh}(TIdx,:);
            end
        end
    end
    
elseif strcmp(Colortype,'Unique')
    for hh = 1:3
        
        MeshMax = max(Surfaces{hh}(:));
        MeshMin = min(Surfaces{hh}(:));

        StepSize = (MeshMax - MeshMin)/length(CMap);
        Steps = [MeshMin:StepSize:MeshMax-StepSize]; %Min to Max - 1 
        
        StepVals{hh} = Steps(Steps>=(min(Surfaces{hh}(:))-StepSize)&Steps<=max(Surfaces{hh}(:)));
        CMaps{hh} = CMap(Steps>=(min(Surfaces{hh}(:))-StepSize)&Steps<=max(Surfaces{hh}(:)),:);
        CMapIndex{hh} = 1:length(CMaps{hh});
        for ii = 1:length(Range)
            for jj = 1:length(Range)
                MeshVal = Surfaces{hh}(ii,jj);
                TIdx = max(CMapIndex{hh}(StepVals{hh}<=MeshVal));
                CMapsG{hh}(ii,jj,:) = CMaps{hh}(TIdx,:);
            end
        end
    end    
    
else
    error('pick a propper Colortype')
end

ZPoints{1} = Y1;
ZPoints{2} = Y2;
ZPoints{3} = Y3;

if strcmp(DotCollor,'colormap')
    for hh = 1:3
        for ii = 1:length(ZPoints{hh})
            DotVal =ZPoints{hh}(ii);
            TIdx = max(CMapIndex{hh}(StepVals{hh}<=DotVal));
            if isempty(TIdx)
                TIdx = 1;
            end
            DotCollors{hh}(ii,:) = CMaps{hh}(TIdx,:);
        end
    end
elseif strcmp(DotCollor,'r')
    for hh = 1:3
        for ii = 1:length(ZPoints{hh})
            DotCollors{hh}(ii,:) = [1,0,0];
        end
    end
else
    error('pick a propper Colortype')
end




%Plot Figure_______________________________________________________________
figure('renderer','painters')
sgtitle(['Behavior Of Signals Under General Wind Loading (DLC ' num2str(Case) ')'])

for ii = 1:3
    subplot(1,3,ii);
    hold on
%     if strcmp(Colortype,'Same')
%         mesh(Range,Range,Surfaces{ii}-50,CMapsG{ii},'FaceAlpha','0.0')
%     else
%         mesh(Range,Range,Surfaces{ii})
%     end
    scatter3(NORMNACELLE,NORMPITCH,ZPoints{ii}-50,5,DotCollors{ii},'filled','MarkerFaceAlpha',0.1,'MarkerEdgeAlpha',0.1)
     if ii == 2
        colorbar('southoutside')
        StepVals{ii} = [-50:10:50];
    end     
    contour(Range,Range,Surfaces{ii},StepVals{ii},'k','ShowText','on')
    hold off
    title(['Blade ' num2str(ii)])
    ylabel('Platform Pitch')
    xlabel('Nacelle Acceleration')
    zlim([-100,0])

    ylim([-3,3])
    xlim([-3,3])

    
end


% 
% 
% subplot(1,3,2);
% hold on
% scatter3(NORMNACELLE,NORMPITCH,Y2,5,'filled','MarkerFaceAlpha',0.1,'MarkerEdgeAlpha',0.2,'MarkerFaceColor','r','MarkerEdgeColor','r')
% 
% mesh(Range,Range,Surface2)
% hold off
% title('Blade 2')
% ylabel('Norm. Platform Pitch')
% xlabel('Norm. Nacel Acceleration')
%  
% subplot(1,3,3);
% hold on
% scatter3(NORMNACELLE,NORMPITCH,Y3,5,'filled','MarkerFaceAlpha',0.1,'MarkerEdgeAlpha',0.2,'MarkerFaceColor','r','MarkerEdgeColor','r')
% 
% mesh(Range,Range,Surface3)
% hold off
% title('Blade 3')
% ylabel('Norm. Platform Pitch')
% xlabel('Norm. Nacel Acceleration')
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 


% 
% %%Create vectors out of surface's XData and YData
% x=x(1,:);
% y=y(:,1);
% %%Divide the lengths by the number of lines needed
% xnumlines = 10; % 10 lines
% ynumlines = 10; % 10 partitions
% xspacing = round(length(x)/xnumlines);
% yspacing = round(length(y)/ynumlines);
% %%Plot the mesh lines 
% % Plotting lines in the X-Z plane
% hold on
% for i = 1:yspacing:length(y)
%     Y1 = y(i)*ones(size(x)); % a constant vector
%     Z1 = z(i,:);
%     plot3(x,Y1,Z1,'-k');
% end
% % Plotting lines in the Y-Z plane
% for i = 1:xspacing:length(x)
%     X2 = x(i)*ones(size(y)); % a constant vector
%     Z2 = z(:,i);
%     plot3(X2,y,Z2,'-k');
% end
% hold off


%% Pitch angle outputs


figure



for iCase = 1:12
subplot(3,4,iCase)
title (num2str(iCase))
hold on
plot(SimOut{iCase,1}.Channels(:,5));
plot(SimOut{iCase,1}.Channels(:,6));
plot(SimOut{iCase,1}.Channels(:,7));
hold off

end




%% check
Fs = 80;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = length(NORMNACELLE);             % Length of signal
t = (0:L-1)*T;        % Time vector


X = NORMNACELLE;







Y = fft(X);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
figure
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')
xlim([0,2.5])






%% Controler 2 Plot
PIn = [-3:0.01:3] ;
POut = sin(cos(tanh(PIn)-0.832));



figure
% for iCase = 1:12
% subplot(3,4,iCase)
% 
% PITCH = SimOut{iCase,1}.Channels(:,Pnum);
% NORMPITCH = (PITCH - mlc.parameters.problem_variables.BaselineMean(Pnum)) ./ mlc.parameters.problem_variables.BaselineDetrendRMS(Pnum);





hold on
title(['Blade 2 Equation Platform Pitch Portion (DLC',num2str(Case),')'])


yyaxis left
histogram(NORMPITCH,20,'Normalization','pdf')
ylim([-0.3,1])
ylabel('PDF of Normalized Platform Pitch Signal')

yyaxis right
plot(PIn,POut)
ylim([-0.3,1])
plot(PIn,0*POut,'Color','k')
ylabel('Sin(Cos(tanh(PtfmPtch)-0.832))')

xlabel('Normalized Platform Pitch Signal')
% end