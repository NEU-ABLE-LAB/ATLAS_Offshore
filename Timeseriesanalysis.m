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
   FastPath = 'D:\Documents\GitHub\ATLAS_FAST-par';
   MLCPath = 'D:\Documents\GitHub\ATLAS_Offshore';
   BestAndBaseline = {'Thetaout = [0;0;0]; X0 = [0; 0; 0]; Xdot = [0; 0; 0]; u = [OutData; X]; y = [	((sin((cos((((sin(tanh(u(34))) + u(24)) + u(24)) - tanh((my_div(2.932,(my_div(u(113),(sin(sin(tanh(u(34)))) - u(107))))))))) + (sin(my_log((-0.731))) + u(24)))) + u(24)) + u(34));  		((sin(cos((tanh(u(34)) - tanh((my_div((-1.475),(-1.233))))))) + u(24)) * (3.824 + 8.627));  		u(34);  		my_log(sin(6.03));  		(8.254 + (-2.644));  		(-9.104)]; Thetaout(1) = y(1); Thetaout(2) = y(2); Thetaout(3) = y(3); Xdot(1) = y(4); Xdot(2) = y(5); Xdot(3) = y(6); ', 'Thetaout = [0;0;0]; X0 = [0; 0; 0]; Xdot = [0; 0; 0]; u = [OutData; X]; y = [0; 0; 0; 0; 0; 0]; Thetaout(1) = y(1); Thetaout(2) = y(2); Thetaout(3) = y(3); Xdot(1) = y(4); Xdot(2) = y(5); Xdot(3) = y(6);' };
   [CF, SimOut, Costs, pMetrics] = MLC_PostEval(BestAndBaseline, mlc.parameters, FastPath, MLCPath);
   save('BestandBLSimout.mat','CF','SimOut','Costs','pMetrics')
end

%%plot Fast-Par Plots
plotTag = struct('Rel_FreqComp',             'plot', ...                    % Relative contribution by frequency and component                             
                 'Rel_Comp',                 'plot', ...                    % Relative contribution per component
                 'Abs_FreqComp',             'plot', ...                    % Absolute contribution by frequency and component
                 'Abs_Comp',                 'plot', ...                    % Absolute contribution per component
                 'Combine',                  'yes');                       % 'yes' will combine all controlers into one plot, 

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
load('BestandBLSimout.mat')
load('20201203_062004mlc_ae')
ChannelNames = SimOut{1,1}.ChanName;


%Hard Code needed chanels now bewcause im lazy
Pnum = 34;
Nnum = 24;
Tnum = 107;

Cases = [1,6,7,8,10,12];
figure
for iCase = [1:6]
    Case = Cases(iCase);
    
    PITCH = SimOut{Case,1}.Channels(:,Pnum);
    TIME = SimOut{Case,1}.Channels(:,1);
    BLPITCH = SimOut{Case,2}.Channels(:,Pnum);

    subplot(2,3,iCase);
    plot(TIME,PITCH,TIME,BLPITCH);
    ylabel('platform pitch (Deg)');
    xlabel('Time (s)');
    title(strcat('Load Case  ',num2str(Case)));
       
end
legend('MLC Controler','Baseline Controler')




Case = 1 ;   
PITCH = SimOut{Case,1}.Channels(:,Pnum);
NACELLE = SimOut{Case,1}.Channels(:,Nnum);
TIE2 = SimOut{Case,2}.Channels(:,Tnum);
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
subplot(1,3,1);
plot(PITCH,Y1,'.')
xlabel('Platform Pitch (PtfmPitch)')
ylabel('Controler Output (Blade 1)')
subplot(1,3,2);
plot(NACELLE,Y1,'.')
xlabel('Nacelle Acceleration (NcIMUTAxs)')
ylabel('Controler Output (Blade 1)')
subplot(1,3,3);
plot(TIE2,Y1,'.')
xlabel('Tension in Tie 2 (T_2)')
ylabel('Controler Output (Blade 1)')


Range = [-3:.05:3];
Surface1 = zeros(length(Range),length(Range));
Surface2 = Surface1;
Surface3 = Surface1;

for ii = 1:length(Range) 
    iPitch = Range(ii);
    for jj = 1:length(Range)
      iNacelle = Range(jj);
      Surface1(ii,jj) = sin(cos(sin(tanh(iPitch)) + 2*iNacelle) -0.136 + iNacelle) + iNacelle + iPitch;
      Surface2(ii,jj) = 12.45*(sin(cos((tanh(iPitch) - 0.832))) + iNacelle);
      Surface3(ii,jj) = iPitch;
   end
end

figure
subplot(1,3,1);
mesh(Range,Range,Surface1)
title('Blade 1')
ylabel('Platform Pitch')
xlabel('Nacel acceleration')

subplot(1,3,2);
mesh(Range,Range,Surface2)
title('Blade 2')
ylabel('Platform Pitch')
xlabel('Nacel acceleration')

subplot(1,3,3);
mesh(Range,Range,Surface3)
title('Blade 3')
ylabel('Platform Pitch')
xlabel('Nacel acceleration')



