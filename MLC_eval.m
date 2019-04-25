%% MLC_eval Evaluates the fitness of an individual for a single case
function J = MLC_eval(ind, MLC_params, ~, ~)
try
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

    %% Setup simulation

    % Parse and apply expressions indvidual
    exprs = MLC_exprs(ind.formal, MLC_params);
    
    % Randomly choose a design load case
    caseN = randi(length(runCases));

    %% Run simulation

    % Create SimulationInput object
    simIn = Simulink.SimulationInput(sysMdl);

    % Set presimulation function
    simIn = FASTPreSim(simIn,...
            runCases{caseN}, ...
            @(pSim)hSetControllerParameter(pSim,exprs), ...
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

    catch e

        warning(e.message)
        J = MLC_params.badvalue;

        clear mex;
        return
        
    end
    
catch e
    
    warning(e.message)    
    J = MLC_params.badvalue;
    
end

clear mex;
end