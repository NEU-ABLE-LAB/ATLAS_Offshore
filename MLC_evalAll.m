%% MLC_eval Evaluates the fitness of an individual
function simOut = MLC_evalAll(ind, MLC_params, ~, ~)
%% Extract MLC problem variables specified when calling `MLC_cfg()`

% Design cases
runCases = MLC_params.problem_variables.runCases;

% Simulink models
sysMdl = MLC_params.problem_variables.sysMdl;
ctrlMdl = MLC_params.problem_variables.ctrlMdl;

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

% Sensor information
nSensors = MLC_params.sensors;

%% Load the simulink model for editing parameters
%   Work in a temporary directory
%   Important for parfor workers

% Setup tempdir and cd into it
tmpDir = tempname;
tmpCtrlMdl = split(tmpDir,filesep);
tmpCtrlMdl = tmpCtrlMdl{end};
mkdir(tmpDir);
cd(tmpDir);
try
    copyfile([MLC_params.problem_variables.ctrlFolder ctrlMdl '.slx'],...
        ['./' tmpCtrlMdl '.slx']);
catch e
    warning('Could not find file to copy')
    rethrow(e);
end

% Load the model on the worker
% load_system(tmpSysMdl)
load_system(tmpCtrlMdl)

%% Parse and apply expressions indvidual

% Extract expression for each controller
exprs = ind.formal;

% Convert from MLC sensor notation to Simulink signal indexing
for exprN = 1:length(exprs)
    for sensorN = 1:nSensors

        % Replace senor name with indexed input signal
        exprs{exprN} = regexprep(exprs{exprN}, ...
            sprintf('(^|\\W)S%d(?=\\W|$)',sensorN-1),...
            sprintf('$1u(%d)',...
                MLC_params.problem_variables.sensorIdxs(sensorN)));

        % Replace `.*` with `*`
        %   Since the `fcn` Simulink blocks don't support `.*`
        exprs{exprN} = strrep(exprs{exprN},'.*','*');

    end
end

if any(contains(exprs,'$'))
    disp(exprs')
    error('MLC_eval: Expression contained ''$'' after parsing');
end

% Controller types
ctrlTypes = {'direct_signal','integral_signal'};

% Insert the expressions into the model
for bladeN = 1:3
    for bladeCtrlN = 1:2 % Each blade has two controllers

        % Get `Fcn` block handle
        hb = find(slroot, '-isa', 'Stateflow.EMChart', 'Path', ...
            sprintf('%s/pitch_ctrl_%d/%s',...
                tmpCtrlMdl,bladeN,ctrlTypes{bladeCtrlN}));

        % Extract expression
        expr = exprs{bladeN*bladeCtrlN};

        % Convert into a function
        fcnText = sprintf('function y = fcn(u)\ny = %s;', expr);

        % Set expression into blocks
        hb.Script = fcnText;

    end
end

%% Run simulation

numSims = numel(runCases);

% Add parameters to controller model workspace
fstFName  = [FASTInputFolder runCases{caseN} '.fst'];
Parameter = fSetSimulinkParameters(fstFName, ...
    hSetControllerParameter); 
hws = get_param(tmpCtrlMdl,'modelWorkspace');
hws.assignin('Parameter',Parameter);

% 3) Create an array of SimulationInput objects and specify the sweep value for each simulation
simIn(1:numSims) = Simulink.SimulationInput(model);
simOut = cell(numSims,1);

for idx = 1:numSims

    % Create SimulationInput object
    simIn(idx) = Simulink.SimulationInput(sysMdl);

    % Change control model to temporary copy
    simIn(idx) = simIn(idx).setBlockParameter(...
        [sysMdl '/CPC_IPC/MLC_IPC_ctrl'],...
        'ModelFile',[tmpCtrlMdl '.slx']);

    % Set presimulation function
    simIn(idx) = FASTPreSim(simIn(idx),...
            runCases{caseN}, ...
            @(x)hSetControllerParameter(x), ...
            RootOutputFolder, ...
            FASTInputFolder, ...
            Challenge, statsBase);

    % Set postsimulation function
    simIn(idx) = simIn(idx).setPostSimFcn(...
        @(y) FASTPostSim(y, simIn(idx)));

    % Run simulation
    simOut(idx) = sim(simIn(idx));
    
end

%% Switch all of the workers back to their original folder.

try
    close_system(tmpCtrlMdl, 0);
    cd([MLC_params.problem_variables.RootOutputFolder '../'])
    rmdir(tmpDir,'s');
catch e
    warning(e.message)
end
    
end