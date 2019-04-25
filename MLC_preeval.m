%% MLC_preeval Pre-evaluation of individual to determine validity
function isValid = MLC_preeval(ind, MLC_params)

isValid = false;

try
    %% Extract MLC problem variables specified when calling `MLC_cfg()`

    % Design cases
    runCases = MLC_params.problem_variables.runCases;

    % Simulink models
    ctrlMdl = MLC_params.problem_variables.ctrlMdl;


    % Handle to function that sets controller parameters
    hSetControllerParameter = ...
            MLC_params.problem_variables.hSetControllerParameter;

    % Directories
    FASTInputFolder = MLC_params.problem_variables.FASTInputFolder;

    % Parse and apply indvidual
    exprs = MLC_exprs(ind.formal, MLC_params);
    
    %% Run simulation

    % constants and specific to a given simulation.
    caseN = 1;
    fstFName  = [FASTInputFolder runCases{caseN} '.fst'];

    % Create SimulationInput object
    simIn = Simulink.SimulationInput(ctrlMdl);
    
    % Set simulation parameters
    Parameter = fSetSimulinkParameters(fstFName, ...
        @(pSim)hSetControllerParameter(pSim, exprs) );
    simIn = simIn.setVariable('Parameter', Parameter, ...
        'Workspace',ctrlMdl); 
    
    % Set simulation data
    t = MLC_params.problem_variables.sensors(:,1); % Time
    channels = MLC_params.problem_variables.sensors; % All Channels
    simIn = simIn.setExternalInput([t, channels]);
    
    % Run simulation
    try
        % Simulation outputs:
        % t, x, theta_c, theta, theta_dot, theta_baseline
        simOut = sim(simIn);
        theta = 180/pi * simOut.yout.get('theta').Values.Data;

    catch e
        
        % If the open loop controller returns an error
        %   then the controller is not valid
        if MLC_params.verbose > 1
            warning(e.message)
            disp('  MLC_PREEVAL: Simulation returned error');
        end
        
        return
    end

    %% Check validity
    % Saturation blocks in the model will prevent signals that are too large
    % Assert statements in the model will catch pitch speed limits

    % The signal should have some variation (e.g. an RMS greater than 1 deg)
    theta_min_rsm = 1.0;
    if all(rms(detrend(theta)) > theta_min_rsm)
        isValid = true;
    else
        if MLC_params.verbose > 1
            disp('  MLC_PREEVAL: Signal did not change');
        end
    end

catch e
    warning(e.message)
end
end