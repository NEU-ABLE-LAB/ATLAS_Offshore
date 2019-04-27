%% MainMLC
% Use MLC to create a controller

restoredefaultpath;
clear all;
close all;
clc;
dbstop if error

%% Initialization
% ref: Main.m
addpath(pwd)
addpath(genpath([pwd,'/_Functions']));  % Matlab functions for cost function and running cases - READ ONLY
addpath(genpath([pwd,'/_Controller'])); % Simulink model, where user scripts and models are placed
addpath(genpath([pwd,'/OpenMLC-Matlab-2'])); % OpenMLC classes and functions

%% Script Parameters
% ref: Main.m

Challenge              = 'Offshore'                 ; % 'Offshore' or 'Onshore', important for cost function
FASTInputFolder        = [pwd '/_Inputs/LoadCases/'] ; % directory of the FAST input files are (e.g. .fst files)
case_file              = [pwd '/_Inputs/_inputs/Cases.csv']; % File defining the cases that are run
BaselineFolder         = [pwd '/_BaselineResults/'] ; % Folder where "reference simulations are located"
RootOutputFolder       = [pwd '/_Outputs/']         ; % Folder where the current simulation outputs will be placed
ctrlFolder             = [pwd '/_Controller/']      ; % Location of Simulink files
% All paths have to be absolute because of parallelization

%% Script Preprocessing

% Load case and metrics init
CasesBase = fReadCases(case_file); % DLC Cases
pMetricsBC = fMetricVars(CasesBase, Challenge); % Parameters for the metrics computation

% Compute folder stats and spectra - or load them from a file
PreProFile= [BaselineFolder 'PrePro_' Challenge '.mat'];
if ~exist(PreProFile,'file')
    statsBase = fComputeOutStats(BaselineFolder, pMetricsBC, ...
        CasesBase, PreProFile);
else
    statsBase = load(PreProFile);
end

% Evaluate metrics and cost function
metricsBase = fEvaluateMetrics(statsBase, pMetricsBC);

%% Model Parameters
% ref: Main.m

% path to the Simulink model (should be in the folder `_Controller`, saved as a `.slx` file)
sysMdl = 'MLC_IPC_sys';
ctrlMdl = 'MLC_IPC_ctrl'; % Reference model for controller

% Input file specification name
runCases = CasesBase.Names;

% handle to the function which sets the Controller parameter (should be in the folder '_Controller')
hSetControllerParameter = @fSetControllerParametersOffshore; 

%% MLC Parameters
iPopFile = '';
% iPopFile = 'MLC_out.mat';
MLC_params = MLC_cfg(runCases ,sysMdl, ctrlMdl, hSetControllerParameter, ...
    ctrlFolder, BaselineFolder, RootOutputFolder, FASTInputFolder, ...
    Challenge, statsBase, iPopFile);

%% Test MLC

% ind = struct('formal',{{'S0*0.5','2*S1*0.5','2*0'}});
% 
% isValid = MLC_preeval(ind, MLC_params);
% if isValid
%     disp('Valid')
% end

% parfor k = 1
%     J = MLC_eval(ind,MLC_params);
% end

%% Run MLC

% Create a MLC object
% mlc=MLC2(MLC_params); 

% Restart previous MLC
load('save_GP/20190426-0056/20190426_172452mlc_be.mat');
                      
% Launch GP for 50 generations and displays the best individual if
% implemented in the evaluation function at the end of each generation
% evaluation
mlc.go(50,3)