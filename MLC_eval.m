%% MLC_eval Evaluates the fitness of an individual
function J = MLC_eval(ind, MLC_params, ~, ~)

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
currDir = pwd;
addpath(currDir);
tmpDir = tempname;
mkdir(tmpDir);
cd(tmpDir);

% Create temporary copies of the models in the worker working directory
tmpMdlSfx = split(tmpDir,filesep);
tmpMdlSfx = tmpMdlSfx{end}; % Append the model name with the temporary directory name
% tmpSysMdl = [sysMdl tmpMdlSfx];
% copyfile([currDir '/_Controller/' sysMdl '.slx'],...
%     ['./' tmpSysMdl '.slx']);
tmpCtrlMdl = [ctrlMdl tmpMdlSfx];
copyfile([currDir '/_Controller/' ctrlMdl '.slx'],...
    ['./' tmpCtrlMdl '.slx']);

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
            sprintf('(^|\\W)S%d(\\W|$)',sensorN-1),...
            sprintf('$1u(%d)$2',...
                MLC_params.problem_variables.sensorIdxs(sensorN)));
            
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

%% Setup simulation

% Randomly choose a design load case
caseN = randi(length(runCases));

%% Run simulation

% Add parameters to controller model workspace
caseN = 1;
fstFName  = [FASTInputFolder runCases{caseN} '.fst'];
Parameter = fSetSimulinkParameters(fstFName, hSetControllerParameter); 
hws = get_param(tmpCtrlMdl,'modelWorkspace');
hws.assignin('Parameter',Parameter);

% Create SimulationInput object
simIn = Simulink.SimulationInput(sysMdl);

% Change control model to temporary copy
simIn = simIn.setBlockParameter(...
    'MLC_IPC_sys/Participant''s New Blade Pitch Control (CPC + IPC)/MLC_IPC_ctrl',...
    'ModelFile',[tmpCtrlMdl '.slx']);

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
    if MLC_params.verbose
        disp(exprs)
        disp(J)
    end
    
catch
    
    J = MLC_params.badvalue;
    clear mex;
    
    % Switch all of the workers back to their original folder.
    close_system(tmpCtrlMdl, 0);
    cd(currDir);
    rmdir(tmpDir,'s');
    rmpath(currDir);
    
end

%% Switch all of the workers back to their original folder.
close_system(tmpCtrlMdl, 0);
cd(currDir);
rmdir(tmpDir,'s');
rmpath(currDir);


end