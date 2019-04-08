%% FASTPostSim Simulink post simulation file
% ref: fRunFAST.m
function out = FASTPostSim(out,in)

%% Initialization
runCase = in.getVariable('runCase');
runName = in.getVariable('runName');
FASTInputFolder = in.getVariable('FASTInputFolder');
OutputFolder = in.getVariable('OutputFolder');
Challenge = in.getVariable('Challenge');
statsBase = in.getVariable('statsBase');

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
if ~exist([FASTInputFolder runName '.SFunc.outb'],'file') || ...
        ~exist([OutputFolder runCase '.SFunc.outb'],'file')
    
    out.CF      = PENALTY;
    out.CF_Comp = PENALTY;
    out.CF_Vars = PENALTY;
    out.CF_Freq = PENALTY;
    return
end

%% Load Output from control
% ref: fRunFAST.m
outCtrlFName = [OutputFolder runCase '.SFunc.outb'];
outCtrl = struct();
[outCtrl.Channels, outCtrl.ChanName, outCtrl.ChanUnit, ...
    outCtrl.FileID, outCtrl.DescStr] = fReadFASTbinary(outCtrlFName);

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

out.Channels = Channels;
out.ChanName = ChanName;
out.ChanUnit = ChanUnit;

out.CF = CF;
out.CF_Comp = CF_Comp;
out.CF_Vars = CF_Vars;
out.CF_Freq = CF_Freq;

end