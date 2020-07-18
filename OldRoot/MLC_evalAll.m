%% MLC_eval Evaluates the fitness of an individual for all cases
function [J, simOut] = MLC_evalAll(ind, MLC_params, ~, hFig, ppm)

%% Extract MLC problem variables specified when calling `MLC_cfg()`

% Design cases
runCases = MLC_params.problem_variables.runCases;

% Simulink models
sysMdl = MLC_params.problem_variables.sysMdl;

% Handle to function that sets controller parameters
hSetControllerParameter = ...
        MLC_params.problem_variables.hSetControllerParameter;

% Directories
RootOutputFolder = MLC_params.problem_variables.RootOutputFolder;
FASTInputFolder = MLC_params.problem_variables.FASTInputFolder;

% Name of challenge
Challenge = MLC_params.problem_variables.Challenge;

% Statistics from baseline controller
statsBase = MLC_params.problem_variables.statsBase;

%% Load the simulink model for editing parameters
%   Work in a temporary directory
%   Important for parfor workers

% Setup tempdir and cd into it
tmpDir = tempname;
mkdir(tmpDir);
cd(tmpDir);

% Create a copy of the model to make changes
tmpSysMdl = split(tmpDir,filesep);
tmpSysMdl = tmpSysMdl{end};
try
    copyfile([MLC_params.problem_variables.ctrlFolder sysMdl '.slx'],...
        ['./' tmpSysMdl '.slx']);
catch e
    warning('Could not find file to copy')
    rethrow(e);
end

% Load the model on the worker
load_system(tmpSysMdl)


%% Setup simulation
% Parse indvidual's expressions 
[~,fcnText] = MLC_exprs(ind.formal, MLC_params);

% Get `Fcn` block handle
hb = find(slroot, '-isa', 'Stateflow.EMChart', 'Path', ...
    sprintf('%s/MLC_IPC/control_law', tmpSysMdl) );

% Insert the expressions into the model    	
	hb.Script = fcnText;

%% Run simulation
numSims = numel(runCases);
simOut = cell(numSims,1);

for simN = 1:numSims
    
    % Setup simulation with presimulation function
    hws = get_param(tmpSysMdl,'modelWorkspace');
    FASTPreSim(hws,...
            runCases{simN}, ...
            @(pSim)hSetControllerParameter(pSim), ...
            RootOutputFolder, ...
            FASTInputFolder, ...
            Challenge, statsBase);
    
    % Try running simulation and computing cost
    try
        
        % Run simulation
        sim(tmpSysMdl);
        clear mex;
        
        % Process output
        simOut{simN} = FASTPostSim([],[], runCases{simN}, ...
            hws.getVariable('runName'), FASTInputFolder, ...
            hws.getVariable('OutputFolder'), Challenge, statsBase);

    catch e

        warning(e.message)
        disp('  MLC_EVALALL: Simulation returned error');
        
        clear mex;
                
    end
    
    ppm.increment();
    
end

%% Calculate aggregate metrics

% Check for bad simulations
%   Missing simulations
%   Bad value simulations
if any(cellfun(@isempty,simOut)) || ... 
        any(cellfun(@(x)(x.CF >= MLC_params.badvalue),simOut))
    
    J = MLC_params.badvalue;
    CF = MLC_params.badvalue;
    CF_Comp = MLC_params.badvalue;
    CF_Vars = MLC_params.badvalue;
    CF_Freq = MLC_params.badvalue;
    
else
    try
        % Compute for good individuals
        [CF, CF_Comp, CF_Vars, CF_Freq, ...
            pMetrics, ~, ~] = ...
            fCostFunctionSimOut(simOut, Challenge, ...
                fEvaluateMetrics(statsBase, ...
                    fMetricVars(runCases, Challenge)));
        J = CF;
    catch
        % Assume bad individual if something is wrong
        J = MLC_params.badvalue;
        CF = MLC_params.badvalue;
        CF_Comp = MLC_params.badvalue;
        CF_Vars = MLC_params.badvalue;
        CF_Freq = MLC_params.badvalue;
    end
end

%% Switch all of the workers back to their original folder.

close_system(tmpSysMdl, 0);
cd([MLC_params.problem_variables.RootOutputFolder '../'])

try
    rmdir(tmpDir,'s');
catch e
    warning(e.message)
end

%% Plot figure if requested

if exist('hFig','var') && ~isempty(hFig) && J>=MLC_params.badvalue
    
    % Plot aggregate metrics
    fCostFunctionPlot(CF, CF_Comp, CF_Vars, CF_Freq, ...
        pMetrics, {'',sysMdl})
    
end
    
end