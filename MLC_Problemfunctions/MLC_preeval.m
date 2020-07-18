%% MLC_preeval Pre-evaluation of individual to determine validity
function isValid = MLC_preeval(ind, MLC_params)
save('TO_PREEVAL')




isValid = false;




try
    %% Extract MLC problem variables specified when calling `MLC_cfg()`

    % Design cases
    runCases = MLC_params.problem_variables.runCases;

    % Simulink models
    ctrlMdl = MLC_params.problem_variables.ctrlMdl;
    load_system(ctrlMdl)

    % Handle to function that sets controller parameters
    hSetControllerParameter = ...
            MLC_params.problem_variables.hSetControllerParameter;

    % Directories
    FASTInputFolder = MLC_params.problem_variables.FASTInputFolder;

    %% Work in a temporary directory
    %   Important for parfor workers
    %   https://www.mathworks.com/help/simulink/ug/not-recommended-using-sim-function-within-parfor.html

    % Setup tempdir and cd into it
    tmpDir = tempname;
    mkdir(tmpDir);
    cd(tmpDir);
    
    % Create a copy of the model to make changes
    tmpCtrlMdl = split(tmpDir,filesep);
    tmpCtrlMdl = tmpCtrlMdl{end};
    try
        copyfile([MLC_params.problem_variables.ctrlFolder ctrlMdl '.slx'],...
            ['./' tmpCtrlMdl '.slx']);
    catch e
        warning('Could not find file to copy')
        rethrow(e);
    end

    % Load the new model on the worker
    load_system(tmpCtrlMdl)    

    %% Setup simulation
    
    % Parse indvidual's expressions 
    [~,fcnText] = MLC_exprs(ind.formal, MLC_params);

    % Get `Fcn` block handle
    hb = find(slroot, '-isa', 'Stateflow.EMChart', 'Path', ...
        sprintf('%s/control_law', tmpCtrlMdl) );

	% Insert the expressions into the model    	
	hb.Script = fcnText;

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
        simOut = sim(tmpCtrlMdl, ...
            'ReturnWorkspaceOutputs','on', ...
            'SaveFormat','Dataset');
        theta = getfield(get(simOut.yout,'theta'),'Values');
        theta = 180/pi * theta;

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

    %% Check validity
    % Saturation blocks in the model will prevent signals that are too large
    % Assert statements in the model will catch pitch speed limits

    % The signal should have some variation (e.g. an RMS greater than 1 deg)
    theta_min_rsm = 1.0;
    if all(theta.var > theta_min_rsm)
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