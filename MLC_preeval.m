%% MLC_preeval Pre-evaluation of individual to determine validity
function isValid = MLC_preeval(ind, parameters)

isValid = false;

%% Extract MLC problem variables specified when calling `MLC_cfg()`

% Design cases
runCases = parameters.problem_variables.runCases;

% Simulink models
ctrlMdl = parameters.problem_variables.ctrlMdl;
load_system(ctrlMdl)

% Handle to function that sets controller parameters
hSetControllerParameter = ...
        parameters.problem_variables.hSetControllerParameter;

% Directories
FASTInputFolder = parameters.problem_variables.FASTInputFolder;
    
% Sensor information
nSensors = parameters.sensors;
    
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

%% Run simulation

% Specify model
simIn = Simulink.SimulationInput(ctrlMdl);

% constants and specific to a given simulation.
caseN = 1;
fstFName  = [FASTInputFolder runCases{caseN} '.fst'];
Parameter = fSetSimulinkParameters(fstFName, hSetControllerParameter); 

% Set parameters to model
simIn = simIn.setVariable('Parameter', Parameter);

% Set model inputs
t = parameters.problem_variables.sensors(:,1); % Time
channels = parameters.problem_variables.sensors; % All Channels
simIn = simIn.setExternalInput([t, channels]);

% Run simulation
try
    simOut = sim(simIn);
catch e
    % If the open loop controller returns an error
    %   then the controller is not valid
    if parameters.verbose > 1
        warning(e.message)
        disp('  MLC_PREEVAL: Simulation returned error');
        disp(exprs')
        return
    end
end

%% Check validity
% Saturation blocks in the model will prevent signals that are too large
% Assert statements in the model will catch pitch speed limits

theta = simOut.yout(:,4:6) * 180/pi;

% The signal should have some variation (e.g. an RMS greater than 1 deg)
if all(rms(detrend(theta)) > 1.0)
    isValid = true;
else
    if parameters.verbose > 1
        disp('  MLC_PREEVAL: Signal did not change');
        disp(exprs')
    end
end



end