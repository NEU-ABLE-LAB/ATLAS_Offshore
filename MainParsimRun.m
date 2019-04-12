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
FASTInputFolder        = [pwd '/_Inputs/LoadCases/'] ; % directory of the FAST input files are (e.g. .fst files)
case_file              = [pwd '/_Inputs/_inputs/Cases.csv']; % File defining the cases that are run
BaselineFolder         = [pwd '/_BaselineResults/'] ; % Folder where "reference simulations are located"
RootOutputFolder       = [pwd '/_Outputs/']         ; % Folder where the current simulation outputs will be placed
% All paths have to be absolute because of parallelization

PENALTY = 1000; % ref: fCostFunction.m

%% Script Preprocessing
% All sections after this should be able to be encapsulated in a parfor

% Load case and metrics init
CasesBase = fReadCases(case_file); % DLC Cases
pMetricsBC = fMetricVars(CasesBase, Challenge); % Parameters for the metrics computation

% Compute folder stats and spectra - or load them from a file
PreProFile= [BaselineFolder 'PrePro_' Challenge '.mat'];
if ~exist(PreProFile,'file')
    statsBase = fComputeOutStats(BaselineFolder, pMetricsBC, CasesBase, PreProFile);
else
    statsBase = load(PreProFile);
end

% Evaluate metrics and cost function
metricsBase = fEvaluateMetrics(statsBase, pMetricsBC);

%% User Parameters
% ref: Main.m

% path to the Simulink model (should be in the folder `_Controller`, saved as a `.slx` file)
if contains(version, '(R2018a)')
    model = 'NREL5MW_Example_IPC_r2018a' ; 
else
    model = 'NREL5MW_Example_IPC' ; 
end
hSetControllerParameter = @fSetControllerParametersOffshore   ; % handle to the function which sets the Controller parameter (should be in the folder '_Controller')

% Input file specification name
runCases = CasesBase.Names;

%% Initialize Parallelization
% ref: https://www.mathworks.com/help/simulink/ug/running-parallel-simulations.html

% 1) Load model
load_system(model);

% 2) Set up the parallelization of parameters
numSims = numel(runCases);

% 3) Create an array of SimulationInput objects and specify the sweep value for each simulation
simIn(1:numSims) = Simulink.SimulationInput(model);
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