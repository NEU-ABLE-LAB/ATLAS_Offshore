%% MLC_finalEval Computes total cost function for individual

%% Initialization
% ref: Main.m
restoredefaultpath;
clear all;close all;clc;
addpath(genpath([pwd,'/_Functions']));  % Matlab functions for cost function and running cases - READ ONLY
addpath(genpath([pwd,'/_Controller'])); % Simulink model, where user scripts and models are placed
addpath(genpath([pwd,'/OpenMLC-Matlab-2'])); % OpenMLC classes and functions

%% Control logic
% Default controller
% exprs = {{'0'},{'0'},{'0'},{'0'},{'0'},{'0'}};

load('20190418_063233mlc_de.mat')
% load('20190418_0707mlc_ae.mat')

min(mlc.population(end).costs(...
    [mlc.population(end).costs]>0))

[~,minIdx] = min(mlc.population(end).costs(...
    mlc.population(end).costs>0));

exprs = mlc.table.individuals(...
    mlc.population(end).individuals(minIdx)).formal';

nSensors = mlc.parameters.problem_variables.nSensors;
sensorIdxs = mlc.parameters.problem_variables.sensorIdxs;

% handle to the function which sets the Controller parameter (should be in the folder '_Controller')
hSetControllerParameter = @(x)fSetControllerParametersOffshore(...
    x,mlc.parameters);

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
% model = 'NREL5MW_Example_IPC';
model = 'FINAL_MLC_IPC' ; 
if contains(version, '(R2018a)')
    model = [model '_r2018a']; 
end

% Input file specification name
runCases = CasesBase.Names;

%% Set control logic

% Load model
load_system(model);

% Convert from MLC sensor notation to Simulink signal indexing
for exprN = 1:length(exprs)
    for sensorN = 1:nSensors
        
        % Replace senor name with indexed input signal
        exprs{exprN} = regexprep(exprs{exprN}, ...
            sprintf('(^|\\W)S%d(\\W|$)',sensorN-1),...
            sprintf('$1u(%d)$2', sensorIdxs(sensorN)));
            
        % Replace `.*` with `*`
        %   Since the `fcn` Simulink blocks don't support `.*`
        exprs{exprN} = strrep(exprs{exprN},'.*','*');
            
    end
end

% Controller types
ctrlTypes = {'direct_signal','integral_signal'};

% Insert the expressions into the model
for bladeN = 1:3
    for bladeCtrlN = 1:2 % Each blade has two controllers
        
        % Get `Fcn` block handle
        hb = find(slroot, '-isa', 'Stateflow.EMChart', 'Path', ...
            sprintf('%s/MLC_IPC/pitch_ctrl_%d/%s',...
                model,bladeN,ctrlTypes{bladeCtrlN}));
            
        % Extract expression
        expr = exprs{bladeN*bladeCtrlN};

        % Convert into a function
        fcnText = sprintf('function y = fcn(u)\ny = %s;', expr);
        
        % Set expression into blocks
        hb.Script = fcnText;
    
    end
end

% Save the system for reference by parallel agents
save_system(model)
close_system(model)

clear mex

%% Initialize Parallelization
% ref: https://www.mathworks.com/help/simulink/ug/running-parallel-simulations.html

% Set up the parallelization of parameters
numSims = numel(runCases);

% Create an array of SimulationInput objects and specify the sweep value for each simulation
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
