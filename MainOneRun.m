%% oneRun
% This script runs one load case
%
% Modeled from `Main.c` and `fRunFAST.m`

%% Initialization
% ref: Main.m

restoredefaultpath;
clear all;close all;clc;
addpath(genpath([pwd,'/_Functions']));  % Matlab functions for cost function and running cases - READ ONLY
addpath(genpath([pwd,'/_Controller'])); % Simulink model, where user scripts and models are placed

%% User Parameters
% ref: Main.m

SimulinkModelFile       = 'NREL5MW_Example_IPC.mdl' ; % path to the Simulink model (should be in the folder '_Controller')
hSetControllerParameter = @fSetControllerParametersOffshore   ; % handle to the function which sets the Controller parameter (should be in the folder '_Controller')
RootOutputFolder            = '_Outputs/' ; % Folder where the current simulation outputs will be placed
BaselineFolder          = '_BaselineResults/'; % Folder where "reference simulations are located"

% Input file specification name
runSpec = 'DLC120_ws13_ye000_s1_r1';

%% Script Parameters
% ref: Main.m

Challenge              = 'Offshore'                 ; % 'Offshore' or 'Onshore', important for cost function
FASTInputFolder        = '_Inputs/LoadCases/'       ; % directory of the FAST input files are (e.g. .fst files)
case_file              = '_Inputs/_inputs/Cases.csv'; % File defining the cases that are run

%% Script Preprocessing
% All sections after this should be able to be encapsulated in a parfor

% Load case and metrics init
baseCases = fReadCases(case_file); % DLC Cases
pMetrics = fMetricVars(baseCases, Challenge); % Parameters for the metrics computation

% Compute folder stats and spectra - or load them from a file
PreProFile= [BaselineFolder 'PrePro_' Challenge '.mat'];
if ~exist(PreProFile,'file')
    statsBase = fComputeOutStats(folder, pMetrics, Cases, PreProFile);
else
    statsBase = load(PreProFile);
end

% Evaluate metrics and cost function
metricsBase = fEvaluateMetrics(statsBase, pMetrics);

%% Set simulation parameters
% ref: fRunFAST.m

% Prepend simulation name with timestamp
tStamp = [datestr(now,'YYYYmmDD-HHMMSS') '_' dec2hex(randi(2^16),4)]; % Add a random 4 char in case two parallel processes start at the same time
runName = [tStamp '_' runSpec];
OutputFolder = [RootOutputFolder runName '/'];
mkdir(OutputFolder);

% Copy FAST case input files
% This way the output file automatically has the time-stamped name
copyfile([FASTInputFolder runSpec '.fst'], [FASTInputFolder runName '.fst'])
copyfile([FASTInputFolder runSpec '_ED.dat'], [FASTInputFolder runName '_ED.dat'])
copyfile([FASTInputFolder runSpec '_HD.dat'], [FASTInputFolder runName '_HD.dat'])
copyfile([FASTInputFolder runSpec '_IW.dat'], [FASTInputFolder runName '_IW.dat'])
copyfile([FASTInputFolder runSpec '_SD.dat'], [FASTInputFolder runName '_SD.dat'])

% constants and specific to a given simulation.
fstFName  = [FASTInputFolder runName '.fst'];
    fprintf('\n');
    fprintf('-----------------------------------------------------------------------------\n');
    fprintf('>>> Simulating: %s \n',fstFName);
    fprintf('-----------------------------------------------------------------------------\n');
Parameter = fSetSimulinkParameters(fstFName, hSetControllerParameter); 

%% Run simulation
% ref: fRunFAST.m
try
    sim(SimulinkModelFile);
    
    % Move output files to output directory
    movefile([FASTInputFolder runName '.SFunc.outb'], ...
        [OutputFolder runSpec '.SFunc.outb']);
    movefile([FASTInputFolder runName '.SFunc.sum'], ...
        [OutputFolder runSpec '.SFunc.sum']);
    movefile([FASTInputFolder runName '.SFunc.MAP.sum'], ...
        [OutputFolder runSpec '.SFunc.MAP.sum']);
    
catch exception
    % rethrow(exception); % FOR NOW RETHROW!!!
    disp(exception.message)
    ErrorList{end+1}=sprintf('Simulation %s failed: %s', Parameter.FASTfile, exception.message);
    FAST_SFunc(0,0,0,0);% reset sFunction
    
    % Delete duplicated input files
    if exist([OutputFolder runSpec '.SFunc.outb'],'file')
        delete([OutputFolder runSpec '.SFunc.outb'])
    end
    if exist([OutputFolder runSpec '.SFunc.sum'],'file')
        delete([OutputFolder runSpec '.SFunc.sum'])
    end
    if exist([OutputFolder runSpec '.SFunc.MAP.sum'],'file')
        delete([OutputFolder runSpec '.SFunc.MAP.sum'])
    end
    delete([FASTInputFolder runName '.fst'])
    delete([FASTInputFolder runName '_ED.dat'])
    delete([FASTInputFolder runName '_HD.dat'])
    delete([FASTInputFolder runName '_IW.dat'])
    delete([FASTInputFolder runName '_SD.dat'])
end

% Delete duplicated input files
delete([FASTInputFolder runName '.fst'])
delete([FASTInputFolder runName '_ED.dat'])
delete([FASTInputFolder runName '_HD.dat'])
delete([FASTInputFolder runName '_IW.dat'])
delete([FASTInputFolder runName '_SD.dat'])

%% Load Output from control and baseline
% ref: fRunFAST.m
outCtrlFName = [OutputFolder runSpec '.SFunc.outb'];
outCtrl = struct();
[outCtrl.Channels, outCtrl.ChanName, outCtrl.ChanUnit, ...
    outCtrl.FileID, outCtrl.DescStr] = fReadFASTbinary(outCtrlFName);

[Channels, ChanName, ChanUnit, ...
    FileID, DescStr] = fReadFASTbinary(outCtrlFName);

%% Compute file stats
% ref: fCostFunctionFolders.m

% Load case and metrics init
Cases = fRegExpCases(runSpec); % Structure of case properties
pMetrics = fMetricVars(Cases, Challenge); % Parameters for the metrics computation

% Compute folder stats and spectra - or load them from a file
statsCtrl = fComputeOutStats(OutputFolder, pMetrics, Cases);

% Evaluate metrics and cost function
metricsCtrl = fEvaluateMetrics(statsCtrl, pMetrics);

statsRunBase = getBaseStats(statsBase,runSpec);
metricsRunBase = fEvaluateMetrics(statsRunBase, pMetrics);

% Compare to baseline
[CF, CF_Comp, CF_Vars, CF_Freq] = fCostFunction(metricsCtrl.Values, ...
    metricsRunBase.Values, pMetrics);

