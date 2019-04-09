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
    statsBase = fComputeOutStats(folder, pMetricsBC, Cases, PreProFile);
else
    statsBase = load(PreProFile);
end

% Evaluate metrics and cost function
metricsBase = fEvaluateMetrics(statsBase, pMetricsBC);

%% User Parameters
% ref: Main.m
if contains(version, '(R2018a)')
    SimulinkModelFile = 'NREL5MW_Example_IPC_2018a.mdl' ; % path to the Simulink model (should be in the folder '_Controller')
else
    SimulinkModelFile = 'NREL5MW_Example_IPC.mdl' ; % path to the Simulink model (should be in the folder '_Controller')
end
hSetControllerParameter = @fSetControllerParametersOffshore   ; % handle to the function which sets the Controller parameter (should be in the folder '_Controller')

% Input file specification name
runCases = CasesBase.Names;

%% Initialize Parallelization
% ref: https://www.mathworks.com/help/simulink/ug/not-recommended-using-sim-function-within-parfor.html

% 1) Load model and initialize the pool.
model = SimulinkModelFile;
load_system(model);
% parpool;

% 2) Set up the iterations that we want to compute.
nCases = length(runCases);
outSim(nCases) = Simulink.SimulationOutput;
outDat(nCases) = struct();

%% 4) Loop over the number of iterations and perform the
% computation for different parameter values.
for idx = 1:nCases
% parfor idx=1:nCases 
    runCase = runCases{idx};
    
    % switch all workers to a separate tempdir in case 
    % any code is generated for instance for StateFlow, or any other 
    % file artifacts are  created by the model.
    
    % Setup tempdir and cd into it
    currDir = pwd;
    addpath(currDir);
    tmpDir = tempname;
    mkdir(tmpDir);
    cd(tmpDir);
    
    % Load the model on the worker
    load_system(model);
    
    % Prepend simulation name with timestamp
    tStamp = [datestr(now,'YYYYmmDD-HHMMSS') '_' dec2hex(randi(2^16),4)]; % Add a random 4 char in case two parallel processes start at the same time
    runName = [tStamp '_' runCase];
    OutputFolder = [RootOutputFolder runName '/'];
    mkdir(OutputFolder);
    
    % Copy FAST case input files
    % This way the output file automatically has the time-stamped name
    copyfile([FASTInputFolder runCase '.fst'], [FASTInputFolder runName '.fst'])
    copyfile([FASTInputFolder runCase '_ED.dat'], [FASTInputFolder runName '_ED.dat'])
    copyfile([FASTInputFolder runCase '_HD.dat'], [FASTInputFolder runName '_HD.dat'])
    copyfile([FASTInputFolder runCase '_IW.dat'], [FASTInputFolder runName '_IW.dat'])
    copyfile([FASTInputFolder runCase '_SD.dat'], [FASTInputFolder runName '_SD.dat'])

    % constants and specific to a given simulation.
    fstFName  = [FASTInputFolder runName '.fst'];
        fprintf('\n');
        fprintf('-----------------------------------------------------------------------------\n');
        fprintf('>>> Simulating: %s \n',fstFName);
        fprintf('-----------------------------------------------------------------------------\n');
    Parameter = fSetSimulinkParameters(fstFName, hSetControllerParameter); 

    try
        outSim(idx) = sim(model, 'SimulationMode', 'normal');
        
        % Move output files to output directory
        movefile([FASTInputFolder runName '.SFunc.outb'], ...
            [OutputFolder runCase '.SFunc.outb']);
        movefile([FASTInputFolder runName '.SFunc.sum'], ...
            [OutputFolder runCase '.SFunc.sum']);
        movefile([FASTInputFolder runName '.SFunc.MAP.sum'], ...
            [OutputFolder runCase '.SFunc.MAP.sum']);
        
    catch exception
        
        % rethrow(exception); % FOR NOW RETHROW!!!
        disp(exception.message)
        FAST_SFunc(0,0,0,0);% reset sFunction
        
        % Delete duplicated input files
        if exist([OutputFolder runCase '.SFunc.outb'],'file')
            delete([OutputFolder runCase '.SFunc.outb'])
        end
        if exist([OutputFolder runCase '.SFunc.sum'],'file')
            delete([OutputFolder runCase '.SFunc.sum'])
        end
        if exist([OutputFolder runCase '.SFunc.MAP.sum'],'file')
            delete([OutputFolder runCase '.SFunc.MAP.sum'])
        end
        
    end
    clear mex %#ok<CLMEX>
    
    % Delete duplicated input files
    delete([FASTInputFolder runName '.fst'])
    delete([FASTInputFolder runName '_ED.dat'])
    delete([FASTInputFolder runName '_HD.dat'])
    delete([FASTInputFolder runName '_IW.dat'])
    delete([FASTInputFolder runName '_SD.dat'])
    
    % Handle failed simulation
    if ~exist([FASTInputFolder runName '.SFunc.outb'],'file') && ...
            ~exist([OutputFolder runCase '.SFunc.outb'],'file')

        outDat(idx).CF      = PENALTY;
        outDat(idx).CF_Comp = PENALTY;
        outDat(idx).CF_Vars = PENALTY;
        outDat(idx).CF_Freq = PENALTY;
        continue
    end
    
    % Load Output from control
    % ref: fRunFAST.m
    outCtrlFName = [OutputFolder runCase '.SFunc.outb'];
    [Channels, ChanName, ChanUnit, FileID, DescStr] = fReadFASTbinary(...
        outCtrlFName);
    
    % Compute file stats
    % ref: fCostFunctionFolders.m

    % Load case and metrics init
    Cases = fRegExpCases(runCase); % Structure of case properties
    pMetrics = fMetricVars(Cases, Challenge); % Parameters for the metrics computation

    % Compute folder stats and spectra - or load them from a file
    statsCtrl = fComputeOutStats(OutputFolder, pMetrics, Cases);

    % Evaluate metrics and cost function
    metricsCtrl = fEvaluateMetrics(statsCtrl, pMetrics);

    % Extract metrics and cost function for base of this case
    statsRunBase = getBaseStats(statsBase,runCase);
    metricsRunBase = fEvaluateMetrics(statsRunBase, pMetrics);

    % Compare to baseline
    [CF, CF_Comp, CF_Vars, CF_Freq] = fCostFunction(metricsCtrl.Values, ...
        metricsRunBase.Values, pMetrics);
    
    % Return calculated outputs
    outDat(idx).Channels = Channels;
    outDat(idx).ChanName = ChanName;
    outDat(idx).ChanUnit = ChanUnit;

    outDat(idx).CF = CF;
    outDat(idx).CF_Comp = CF_Comp;
    outDat(idx).CF_Vars = CF_Vars;
    outDat(idx).CF_Freq = CF_Freq;
    
    % Switch all of the workers back to their original folder.
    cd(currDir);
    rmdir(tmpDir,'s');
    rmpath(currDir);
    close_system(model, 0);
    
end
