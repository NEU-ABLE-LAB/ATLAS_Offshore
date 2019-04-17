%% MLC_preeval Pre-evaluation of individual to determine validity
function isValid = MLC_preeval(ind, parameters)

isValid = false;

%% Extract MLC problem variables specified when calling `MLC_cfg()`

% Design cases
runCases = parameters.problem_variables.runCases;

% Simulink models
ctrlMdl = parameters.problem_variables.ctrlMdl;


% Handle to function that sets controller parameters
hSetControllerParameter = ...
        parameters.problem_variables.hSetControllerParameter;

% Directories
FASTInputFolder = parameters.problem_variables.FASTInputFolder;
    
% Sensor information
nSensors = parameters.sensors;
    
%% Work in a temporary directory
%   Important for parfor workers

% Setup tempdir and cd into it
currDir = pwd;
addpath(currDir);
tmpDir = tempname;
tmpCtrlMdl = split(tmpDir,filesep);
tmpCtrlMdl = tmpCtrlMdl{end};
mkdir(tmpDir);
cd(tmpDir);
copyfile([currDir '/_Controller/' ctrlMdl '.slx'],...
    ['./' tmpCtrlMdl '.slx']);

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
t = parameters.problem_variables.sensors(:,1); % Time
channels = parameters.problem_variables.sensors; % All Channels
hws.assignin('t',t);
hws.assignin('channels',channels);
set_param(tmpCtrlMdl,'ExternalInput','[t channels]')
set_param(tmpCtrlMdl,'LoadExternalInput','on')

% Set model outputs
% set_param(tmpMdl,'OutputSaveName','[theta,theta_dot]');

% Run simulation
try
    % Simulation outputs:
    % t, x, theta_c, theta, theta_dot, theta_baseline
    [t, ~, theta_c, theta, theta_dot, theta_baseline] = sim(tmpCtrlMdl);
    theta_c = theta_c * 180/pi;
    theta = theta * 180/pi;
    theta_dot = theta_dot * 180/pi;
    theta_baseline = theta_baseline * 180/pi;
    
catch e
    % If the open loop controller returns an error
    %   then the controller is not valid
    if parameters.verbose > 1
        warning(e.message)
        disp('  MLC_PREEVAL: Simulation returned error');
        disp(e.message)
        disp(exprs')
        
        % Switch all of the workers back to their original folder.
        close_system(tmpCtrlMdl, 0);
        cd(currDir);
        rmdir(tmpDir,'s');
        rmpath(currDir);
        
        return
    end
end

Simulink.sdi.cleanupWorkerResources

%% Check validity
% Saturation blocks in the model will prevent signals that are too large
% Assert statements in the model will catch pitch speed limits

% The signal should have some variation (e.g. an RMS greater than 1 deg)
if all(rms(detrend(theta)) > 1.0)
    isValid = true;
else
    if parameters.verbose > 1
        disp('  MLC_PREEVAL: Signal did not change');
        disp(exprs')
    end
end

%% Switch all of the workers back to their original folder.
close_system(tmpCtrlMdl, 0);
cd(currDir);
rmdir(tmpDir,'s');
rmpath(currDir);

end