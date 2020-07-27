%% MLC_Settings
% create a MLC object and save it to the specified folder

restoredefaultpath;
clear all; close all; clc;
dbstop if error

%% Initialization
addpath(pwd)
addpath(genpath([pwd,'/OpenMLC-Matlab-2'])); % OpenMLC classes and functions
addpath(genpath([pwd,'/MLC_Problemfunctions'])); % functions related to the turbine problem 
addpath(genpath([pwd,'/ParforProgMon'])); % Parfor progress monitor 

%% Configure Problem Parameters

% Problem based parameters can be changed within the config function below:
problem_variables = fConfigProblemParams();


%% Configure MLC Parameters

% MLC parameters can be changed within the config function below:
MLC_Params = fConfigMLCParams(problem_variables);

%% Test MLC

% ind = struct('formal',{{'S0*0','2*S1*0','2*0'}});

% isValid = MLC_preeval(ind, MLC_params);
% if isValid
%     disp('Valid')
% end

% parfor k = 1
%     J = MLC_eval(ind,MLC_params);
% end

% simOut = MLC_evalAll(ind,MLC_params);

%% Machine Learning Control

% Create a MLC object
mlc=MLC2(MLC_Params); 

% save MLC Object
fname = [mlc.parameters.savedir,'\',datestr(now,'YYYYmmDD-HHMMSS'),'_MLC_TEST_SETTINGS'];
save(fname,'mlc')
                      
% Launch GP for 50 generations and displays the best individual if
% implemented in the evaluation function at the end of each generation
% evaluation
mlc.go(10,3)