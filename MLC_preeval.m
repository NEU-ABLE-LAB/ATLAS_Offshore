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

    % Sensor information
    nSensors = MLC_params.sensors;

    %% Work in a temporary directory
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
    load_system(tmpCtrlMdl)

    %% Parse and apply indvidual

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
        dips(exprs')
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

    % constants and specific to a given simulation.
    caseN = 1;
    fstFName  = [FASTInputFolder runCases{caseN} '.fst'];
    Parameter = fSetSimulinkParameters(fstFName, hSetControllerParameter); 
    hws = get_param(tmpCtrlMdl,'modelWorkspace');
    hws.assignin('Parameter',Parameter);

    % Set model inputs
    t = MLC_params.problem_variables.sensors(:,1); % Time
    channels = MLC_params.problem_variables.sensors; % All Channels
    hws.assignin('t',t);
    hws.assignin('channels',channels);
    set_param(tmpCtrlMdl,'ExternalInput','[t channels]')
    set_param(tmpCtrlMdl,'LoadExternalInput','on')

    % Run simulation
    try
        % Simulation outputs:
        % t, x, theta_c, theta, theta_dot, theta_baseline
        [~, ~, ~, theta, ~, ~] = sim(tmpCtrlMdl);
        theta = theta * 180/pi;

    catch e
        % If the open loop controller returns an error
        %   then the controller is not valid
        if MLC_params.verbose > 1
            warning(e.message)
            disp('  MLC_PREEVAL: Simulation returned error');
        end
        
        % Switch all of the workers back to their original folder.
        close_system(tmpCtrlMdl, 0);
        cd([MLC_params.problem_variables.RootOutputFolder '../'])
        try
            rmdir(tmpDir,'s');
        catch e
            warning(e.message)
        end

        return
    end

    Simulink.sdi.cleanupWorkerResources

    %% Check validity
    % Saturation blocks in the model will prevent signals that are too large
    % Assert statements in the model will catch pitch speed limits

    % The signal should have some variation (e.g. an RMS greater than 1 deg)
    if all(rms(detrend(theta)) > 1.0)
        isValid = true;
    else
        if MLC_params.verbose > 1
            disp('  MLC_PREEVAL: Signal did not change');
        end
    end

    %% Switch all of the workers back to their original folder.
    close_system(tmpCtrlMdl, 0);
    cd([MLC_params.problem_variables.RootOutputFolder '../'])
    try
        rmdir(tmpDir,'s');
    catch e
        warning(e.message)
    end
catch e
    warning(e.message)
    cd([MLC_params.problem_variables.RootOutputFolder '../'])
end
end