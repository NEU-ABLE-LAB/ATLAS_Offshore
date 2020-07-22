%% MLC_preeval Pre-evaluation of individual to determine validity
function isValid = MLC_preeval(ind, MLC_params)

isValid = false;
try
%% Extract problem variables Needed for the Baseline Controler

% Design cases
runCases = MLC_params.problem_variables.runCases;

% Directories
FASTInputFolder = [MLC_params.problem_variables.FastPath '\_Inputs\LoadCases\'];

%Handel to controler Parameters
hSetControllerParameter = @fSetControllerParametersPreeval;



%% Load the simulink model for editing parameters
%   Work in a temporary directory, Important for parfor workers to work in unique directory

% Setup temporary directory and change it to the current directory
tmpDir = tempname;
mkdir(tmpDir); 
cd(tmpDir);

% Create a copy of the model to make changes
tmpSysMdl = split(tmpDir,filesep);
tmpSysMdl = tmpSysMdl{end};

try
    copyfile(['C:\Users\James\Documents\GitHub\ATLAS_Offshore\MLC_Problemfunctions\Files\MLC_PreEval.mdl'], ['./' tmpSysMdl '.mdl']);
catch e
    warning('Could not find system model file to copy, check Main_par where the system model is defined and make sure the system model is in the correct folder')
    rethrow(e);
end

% Load the model on the worker
load_system(tmpSysMdl)

    

    %% Setup simulation
    
    % Parse indvidual's expressions 
    [~,fcnText] = MLC_MLC2Fast(ind.formal, MLC_params);

    % Get `Fcn` block handle
    hb = find(slroot, '-isa', 'Stateflow.EMChart', 'Path', ...
        sprintf('%s/Control_Law', tmpSysMdl) );

	% Insert the expressions into the model    	
	hb.Script = fcnText;

	%% Run simulation
    % constants and specific to a given simulation.
    caseN = 1;
    fstFName  = [FASTInputFolder runCases{caseN} '.fst'];
    Parameter = fSetSimulinkParameters(fstFName, hSetControllerParameter, MLC_params); 
    hws = get_param(tmpSysMdl,'modelWorkspace');
    hws.assignin('Parameter',Parameter);
    hws.assignin('CParameter',Parameter.CParameter)
    
    % Set model inputs
    t = MLC_params.problem_variables.BaselineSimout(:,1); % Time
    channels = MLC_params.problem_variables.BaselineSimout; % All Channels
    hws.assignin('t',t);
    hws.assignin('channels',channels);
    set_param(tmpSysMdl,'ExternalInput','[t channels]')
    set_param(tmpSysMdl,'LoadExternalInput','on')

    % Run simulation
    try
        
        %Simulation outputs:
        % t, x, theta_c, theta, theta_dot, theta_baseline
        simOut = sim(tmpSysMdl, ...
            'ReturnWorkspaceOutputs','on', ...
            'SaveFormat','Dataset');
        theta = getfield(get(simOut.yout,'theta'),'Values');
        theta = 180/pi * theta;

    catch e
        
        %If the open loop controller returns an error
        %then the controller is not valid
        if MLC_params.verbose > 1
            warning(e.message)
            disp('  MLC_PREEVAL: Simulation returned error');
        end
        
        % Switch all of the workers back to their original folder.
        close_system(tmpSysMdl, 0);
        cd([MLC_params.problem_variables.MLCPath])
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
            disp('  MLC_PREEVAL: Signal did not change. Individual is invalid');
        end
    end

    %% Switch all of the workers back to their original folder.
    close_system(tmpSysMdl, 0);
    cd([MLC_params.problem_variables.MLCPath])
    try
        rmdir(tmpDir,'s');
    catch e
        warning(e.message)
    end
catch e
    warning(e.message)
    cd([MLC_params.problem_variables.MLCPath])
end
end