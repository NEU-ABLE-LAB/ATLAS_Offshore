%% MLC_eval Evaluates the fitness of an individual for all cases
function simOut = MLC_evalAll(ind, MLC_params, ~, ~)

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

% Parse and apply expressions indvidual
exprs = MLC_exprs(ind.formal, MLC_params);


%% Run simulation
numSims = numel(runCases);

% Create an array of SimulationInput objects
simIn(1:numSims) = Simulink.SimulationInput(sysMdl);
simOut = Simulink.SimulationOutput;
simOut(numSims) = simOut;

for simN = 1:numSims

    % Set presimulation function
    simIn(simN) = FASTPreSim(simIn(simN),...
            runCases{simN}, ...
            @(pSim)hSetControllerParameter(pSim,exprs), ...
            RootOutputFolder, ...
            FASTInputFolder, ...
            Challenge, statsBase);

    % Set postsimulation function
    simIn(simN) = simIn(simN).setPostSimFcn(...
        @(y) FASTPostSim(y, simIn(simN)));

    % Run simulation
    simOut(simN) = sim(simIn(simN));
    
end
    
end