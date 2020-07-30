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

%--- General Parameters
% Problem based parameters can be changed within the config function below:
problem_variables = fConfigProblemParams();

%--- Path Info
%Path to FAST_Par
problem_variables.FastPath = 'D:\Documents\GitHub\ATLAS_FAST-par';   % Fast_Par
problem_variables.MLCPath = pwd;

%% Configure MLC Parameters

%--- General Parameters
% MLC parameters can be changed within the config function below:
MLC_Params = fConfigMLCParams(problem_variables);

%--- Generations and Population
MLC_Params.size = 20;                  %*(num)[1000]$N_i$ Population size
Ngens = 20;                            % number of generations to evaluate and evolve

MLC_Params.ev_again_best = 0;          %*(bool)[0] Should elite individuals be reevaluated
MLC_Params.ev_again_nb = 1;            % ?(num)[5] Number off best individuals to reevaluate. Should probably be similar to `elitism`.

MLC_Params.elitism = 1;                %*(num)[10]$N_e$ Number of best individuals to carry over to next generation

%--- Evaluation



%% Machine Learning Control

% Create a MLC object
mlc=MLC2(MLC_Params); 

% save MLC Object
fname = [mlc.parameters.savedir,'\',datestr(now,'YYYYmmDD-HHMMSS'),'_MLC_TEST_SETTINGS'];
save(fname,'mlc')
                      
% Launch GP 
 mlc.go(Ngens,3)