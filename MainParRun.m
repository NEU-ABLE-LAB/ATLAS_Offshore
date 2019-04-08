%% oneRun
% This script runs one load case
%
% Modeled from `Main.m` and `fRunFAST.m`

%% Initialization
% ref: Main.m

restoredefaultpath;
clear all;close all;clc;
addpath(genpath([pwd,'/_Functions']));  % Matlab functions for cost function and running cases - READ ONLY
addpath(genpath([pwd,'/_Controller'])); % Simulink model, where user scripts and models are placed

%% Script Parameters
% ref: Main.m

Challenge              = 'Offshore'                 ; % 'Offshore' or 'Onshore', important for cost function
FASTInputFolder        = '_Inputs/LoadCases/'       ; % directory of the FAST input files are (e.g. .fst files)
case_file              = '_Inputs/_inputs/Cases.csv'; % File defining the cases that are run
BaselineFolder         = '_BaselineResults/'        ; % Folder where "reference simulations are located"

%% Script Preprocessing
% All sections after this should be able to be encapsulated in a parfor

% Load case and metrics init
CasesBase = fReadCases(case_file); % DLC Cases
pMetricsBC = fMetricVars(CasesBase, Challenge); % Parameters for the metrics computation

% Compute folder stats and spectra - or load them from a file
PreProFile= [BaselineFolder 'PrePro_' Challenge '.mat'];
if ~exist(PreProFile,'file')
    statsBase = fComputeOutStats(folder, pMetricsBC, Cases, PreProFile);
else
    statsBase = load(PreProFile);
end

% Evaluate metrics and cost function
metricsBase = fEvaluateMetrics(statsBase, pMetricsBC);

%% User Parameters
% ref: Main.m

SimulinkModelFile       = 'NREL5MW_Example_IPC.mdl' ; % path to the Simulink model (should be in the folder '_Controller')
hSetControllerParameter = @fSetControllerParametersOffshore   ; % handle to the function which sets the Controller parameter (should be in the folder '_Controller')
RootOutputFolder            = '_Outputs/' ; % Folder where the current simulation outputs will be placed

% Input file specification name
runCases = CasesBase.Names;

%% Initialize Parallelization
% ref: https://www.mathworks.com/help/simulink/ug/running-parallel-simulations.html

% 1) Load model
load_system(SimulinkModelFile);

% 2) Set up the parallelization of parameters
numSims = numel(runCases);

% 3) Create an array of SimulationInput objects and specify the sweep value for each simulation
simIn(1:numSims) = Simulink.SimulationInput(SimulinkModelFile);
for idx = 1:numSims
    
    % Initialize the simulation
    simIn(idx) = FASTPreSim(simIn(idx),...
        runCases{idx}, hSetControllerParameter, ...
        RootOutputFolder, FASTInputFolder, ...
        Challenge, statsBase);
    
    % Set postsimulation function
    simIn(idx) = simIn(idx).setPostSimFcn(@(y) FASTPostSim(y, simIn(idx)));
    
end

%% 4) Simulate the model 
% ref: https://www.mathworks.com/help/simulink/ug/running-parallel-simulations.html

simOut = parsim(simIn);