%% FASTPostSim Simulink post simulation file
% ref: fRunFAST.m
%   
% Either provide `in` as a Simulink.SimulationInput object
%   or make `in` empty and specify other parameters
function newOut = FASTPostSim(~,in,...
    runCase, runName, FASTInputFolder, OutputFolder, Challenge, statsBase)

%% Initialization
% Note: getVariables() only exists in r2018b+
if isa(in, 'Simulink.SimulationInput')
    
    runCase = in.Variables(strcmp({in.Variables.Name},...
        'runCase')).Value;
    
    runName = in.Variables(strcmp({in.Variables.Name},...
        'runName')).Value;
    
    FASTInputFolder = in.Variables(strcmp({in.Variables.Name},...
        'FASTInputFolder')).Value;
    
    OutputFolder = in.Variables(strcmp({in.Variables.Name},...
        'OutputFolder')).Value;
    
    Challenge = in.Variables(strcmp({in.Variables.Name},...
        'Challenge')).Value;
    
    statsBase = in.Variables(strcmp({in.Variables.Name},...
        'statsBase')).Value;
    
end

newOut.runCase         = runCase         ;
newOut.runName         = runName         ;
newOut.FASTInputFolder = FASTInputFolder ;
newOut.OutputFolder    = OutputFolder    ;
newOut.Challenge       = Challenge       ;
newOut.statsBase       = statsBase       ;

PENALTY = 1000; % ref: fCostFunction.m

%% Clean up files

% Move output files to output directory
if exist([FASTInputFolder runName '.SFunc.outb'],'file')
    movefile([FASTInputFolder runName '.SFunc.outb'], ...
        [OutputFolder runCase '.SFunc.outb']);
end
if exist([FASTInputFolder runName '.SFunc.sum'],'file')
    movefile([FASTInputFolder runName '.SFunc.sum'], ...
        [OutputFolder runCase '.SFunc.sum']);
end
if exist([FASTInputFolder runName '.SFunc.MAP.sum'],'file')
    movefile([FASTInputFolder runName '.SFunc.MAP.sum'], ...
        [OutputFolder runCase '.SFunc.MAP.sum']);
end

% Delete copies of input files
delete([FASTInputFolder runName '.fst'])
delete([FASTInputFolder runName '_ED.dat'])
delete([FASTInputFolder runName '_HD.dat'])
delete([FASTInputFolder runName '_IW.dat'])
delete([FASTInputFolder runName '_SD.dat'])

%% Handle failed simulation
if ~exist([FASTInputFolder runName '.SFunc.outb'],'file') && ...
        ~exist([OutputFolder runCase '.SFunc.outb'],'file')

    newOut.Channels = [];
    newOut.ChanName = [];
    newOut.ChanUnit = [];
    newOut.CF = PENALTY;
    newOut.CF_Comp = PENALTY;
    newOut.CF_Vars = PENALTY;
    newOut.CF_Freq = PENALTY;

    return
end

%% Load Output from control
% ref: fRunFAST.m
outCtrlFName = [OutputFolder runCase '.SFunc.outb'];

[Channels, ChanName, ChanUnit, ~, ~] = fReadFASTbinary(outCtrlFName);

%% Compute file stats
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

%% Return calculated outputs

newOut.Channels = Channels;
newOut.ChanName = ChanName;
newOut.ChanUnit = ChanUnit;
newOut.CF = CF;
newOut.CF_Comp = CF_Comp;
newOut.CF_Vars = CF_Vars;
newOut.CF_Freq = CF_Freq;
newOut.pMetrics = pMetrics;

clear mex

end