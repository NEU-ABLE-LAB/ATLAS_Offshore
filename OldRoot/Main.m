%% Documentation 
% This script run all load cases, evaluates the cost function and compare it to the baseline

%% Initialization
restoredefaultpath;
clear all;close all;clc;
addpath(genpath([pwd,'/_Functions']));  % Matlab functions for cost function and running cases - READ ONLY
addpath(genpath([pwd,'/_Controller'])); % Simulink model, where user scripts and models are placed

%% User Parameters (can be modified by the contestants)
SimulinkModelFile       = 'NREL5MW_Baseline.mdl' ; % path to the Simulink model (should be in the folder '_Controller')
hSetControllerParameter = @fSetControllerParametersOffshore   ; % handle to the function which sets the Controller parameter (should be in the folder '_Controller')
OutputFolder            = '_Outputs/' ; % Folder where the current simulation outputs will be placed
folders    = {
  '_BaselineResults/','Baseline Results'; % Folder where "reference simulations are located"
  OutputFolder       ,'Model Results'   ; % Folder where the current simulation outputs will be placed
}; % nx2 cell of Folders and Labels. Folder is where the .outb files are, with slash at the end

%% Script Parameters
global Parameter ; % Structure containing all the parameters passed to the Simulink model
Parameter = struct(); % Structure containing all the parameters passed to the Simulink model
Challenge              = 'Offshore'                 ; % 'Offshore' or 'Onshore', important for cost function
FASTInputFolder        = '_Inputs/LoadCases/'       ; % directory of the FAST input files are (e.g. .fst files)
case_file              = '_Inputs/_inputs/Cases.csv'; % File defining the cases that are run

%% Running simulations and copying outputs to chosen folder
fRunFAST(FASTInputFolder, SimulinkModelFile, hSetControllerParameter, ...
    OutputFolder); % function located in _Functions\

%% Evaluation of cost function 
[CF, CF_Comp, CF_Vars, CF_Freq, pMetrics] = fCostFunctionFolders(...
    folders, case_file, Challenge);
for iFolder = 1:size(folders,1)
    fprintf('Cost function: %6.4f  (%s)\n',CF(iFolder),folders{iFolder,2});
end

fCostFunctionPlot (CF, CF_Comp, CF_Vars, CF_Freq, pMetrics, folders);

if any(CF)>=1000
    error('\nSome of the constraints were exceeded (see outputs above). The cost function was set to a disqualifying value.\n')
end
