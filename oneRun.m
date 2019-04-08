%% oneRun
% This script runs one load case
%
% Modeled from `Main.c` and `fRunFAST.m`

%% Initialization
restoredefaultpath;
clear all;close all;clc;
addpath(genpath([pwd,'/_Functions']));  % Matlab functions for cost function and running cases - READ ONLY
addpath(genpath([pwd,'/_Controller'])); % Simulink model, where user scripts and models are placed

%% User Parameters (can be modified by the contestants)
SimulinkModelFile       = 'PAR_NREL5MW_IPC.mdl' ; % path to the Simulink model (should be in the folder '_Controller')
hSetControllerParameter = @fSetControllerParametersOffshore   ; % handle to the function which sets the Controller parameter (should be in the folder '_Controller')
OutputFolder            = '_Outputs/' ; % Folder where the current simulation outputs will be placed
BaselineFolder          = '_BaselineResults/'; % Folder where "reference simulations are located"
folders    = {
  BaselineFolder     ,'Baseline Results'; % Folder where "reference simulations are located"
  OutputFolder       ,'Model Results'   ; % Folder where the current simulation outputs will be placed
}; % nx2 cell of Folders and Labels. Folder is where the .outb files are, with slash at the end

% Input file specification name
runSpec = 'DLC120_ws13_ye000_s1_r1';

%% Script Parameters
global Parameter ; % Structure containing all the parameters passed to the Simulink model
Parameter = struct(); % Structure containing all the parameters passed to the Simulink model
Challenge              = 'Offshore'                 ; % 'Offshore' or 'Onshore', important for cost function
FASTInputFolder        = '_Inputs/LoadCases/'       ; % directory of the FAST input files are (e.g. .fst files)

%% Setting controller parameters

runName = [datestr(now,'YYYYmmDD-HHMMSS_') runSpec];

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

% Create non-global parameter to use when parallelized
Parameter0 = Parameter;
clear Parameter

%% Run simulation
try
    sim(SimulinkModelFile);
    
    % Move output files to output directory
    movefile([FASTInputFolder runName '.SFunc.outb'], ...
        [OutputFolder runName '.SFunc.outb']);
    movefile([FASTInputFolder runName '.SFunc.sum'], ...
        [OutputFolder runName '.SFunc.sum']);
    movefile([FASTInputFolder runName '.SFunc.MAP.sum'], ...
        [OutputFolder runName '.SFunc.MAP.sum']);
    
catch exception
    % rethrow(exception); % FOR NOW RETHROW!!!
    disp(exception.message)
    ErrorList{end+1}=sprintf('Simulation %s failed: %s', Parameter.FASTfile, exception.message);
    FAST_SFunc(0,0,0,0);% reset sFunction
end
clear mex

% Delete duplicated input files
delete([FASTInputFolder runName '.fst'])
delete([FASTInputFolder runName '_ED.dat'])
delete([FASTInputFolder runName '_HD.dat'])
delete([FASTInputFolder runName '_IW.dat'])
delete([FASTInputFolder runName '_SD.dat'])

%% Load Output
outCtrlFName = [OutputFolder runName '.SFunc.outb'];
outCtrl = struct();
[outCtrl.Channels, outCtrl.ChanName, outCtrl.ChanUnit, ...
    outCtrl.FileID, outCtrl.DescStr] = fReadFASTbinary(outCtrlFName);

[Channels, ChanName, ChanUnit, ...
    FileID, DescStr] = fReadFASTbinary(outCtrlFName);

% Load reference if present
outBaseFName = [BaselineFolder runSpec '.SFunc.outb'];
if exist(outBaseFName,'file')
    outBase = struct();
    [outBase.Channels, outBase.ChanName, outBase.ChanUnit, ...
        outBase.FileID, outBase.DescStr] = fReadFASTbinary(outBaseFName);    
end