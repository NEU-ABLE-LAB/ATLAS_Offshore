%% MLC_eval Evaluates the fitness of an individual
function J = MLC_eval(ind, parameters, ~, ~)

%% Extract MLC problem variables specified when calling `MLC_cfg()`

% Design cases
runCases = parameters.problem_variables.runCases;

% Simulink models
sysMdl = parameters.problem_variables.sysMdl;
ctrlMdl = parameters.problem_variables.ctrlMdl;

% Handle to function that sets controller parameters
hSetControllerParameter = ...
        parameters.problem_variables.hSetControllerParameter;

% Directories
RootOutputFolder = parameters.problem_variables.RootOutputFolder;
FASTInputFolder = parameters.problem_variables.FASTInputFolder;

% Name of challenge
Challenge = parameters.problem_variables.Challenge;

% Statistics from baseline controller
statsBase = parameters.problem_variables.statsBase;

% Sensor information
nSensors = parameters.sensors;

%% Load the simulink model for editing parameters
load_system(sysMdl)
load_system(ctrlMdl)

%% Parse and apply indvidual

% Extract expression for each controller
exprs = ind.formal;
if parameters.verbose
    disp(exprs)
end

% Convert from MLC sensor notation to Simulink signal indexing
for exprN = 1:length(exprs)
    for sensorN = 1:nSensors
        
        % Replace senor name with indexed input signal
        exprs{exprN} = regexprep(exprs{exprN}, ...
            sprintf('(^|\\W)S%d(\\W|$)',sensorN-1),...
            sprintf('$1u(%d)$2',...
                parameters.problem_variables.sensorIdxs(sensorN)));
            
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
            sprintf('MLC_IPC_ctrl/pitch_ctrl_%d/%s',...
                bladeN,ctrlTypes{bladeCtrlN}));
            
        % Extract expression
        expr = exprs{bladeN*bladeCtrlN};

        % Convert into a function
        fcnText = sprintf('function y = fcn(u)\ny = %s;', expr);
        
        % Set expression into blocks
        hb.Script = fcnText;
    
    end
end

%% Setup simulation

% Randomly choose a design load case
caseN = randi(length(runCases));

%% Run simulation

% Specify model
simIn = Simulink.SimulationInput(sysMdl);

% Set presimulation function
simIn = FASTPreSim(simIn,...
        runCases{caseN}, ...
        @(x)hSetControllerParameter(x), ...
        RootOutputFolder, ...
        FASTInputFolder, ...
        Challenge, statsBase);

% Set postsimulation function
simIn = simIn.setPostSimFcn(@(y) FASTPostSim(y, simIn));

try
    % Run simulation
    simOut = sim(simIn);
    
    % Compute cost from output
    J = simOut.CF;
    
catch
    J = parameters.badvalue;
    clear mex;
end

end