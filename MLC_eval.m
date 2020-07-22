%% MLC_eval Evaluates the fitness of an individual for a single case
%
%   INPUTS
%       ind - Current mlc.individual
%       MLC_params - mlc.parameters
%       idvN - Individual number???
%       hFig - Figure handle for plot
%       genN - Current generation
%
function [J, simOut] = MLC_eval(ind, MLC_params, idvN, hFig, caseN)
simOut = {};
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

    %% Load the simulink model for editing parameters
    %   Work in a temporary directory
    %   Important for parfor workers

    % Setup tempdir and cd into it
    tmpDir = tempname;
    mkdir(tmpDir);
    cd(tmpDir);

	% Create a copy of the model to make changes
    tmpSysMdl = split(tmpDir,filesep);
    tmpSysMdl = tmpSysMdl{end};
    try
        copyfile([MLC_params.problem_variables.ctrlFolder sysMdl '.slx'],...
            ['./' tmpSysMdl '.slx']);
    catch e
        warning('Could not find file to copy')
        rethrow(e);
    end

    % Load the model on the worker
    load_system(tmpSysMdl)
    
    %% Setup simulation

    % Parse indvidual's expressions 
    [~,fcnText] = MLC_exprs(ind.formal, MLC_params);
    
    % Get `Fcn` block handle
    hb = find(slroot, '-isa', 'Stateflow.EMChart', 'Path', ...
       sprintf('%s/MLC_IPC/control_law', tmpSysMdl) );

	% Insert the expressions into the model    	
	hb.Script = fcnText;

    %% Run simulation

    % Choose a design load case
    if ~(exist('caseN','var') && ~isempty(caseN))
        
        % Chose a random case
        caseN = randi(length(runCases));
        
    end
    
    % Setup simulation with presimulation function
    hws = get_param(tmpSysMdl,'modelWorkspace');
    FASTPreSim(hws,...
            runCases{caseN}, ...
            @(pSim)hSetControllerParameter(pSim), ...
            RootOutputFolder, ...
            FASTInputFolder, ...
            Challenge, statsBase);

    % Try running simulation and computing cost
    try

        % Run simulation
        sim(tmpSysMdl);
        
        % Process output
        simOut = FASTPostSim([],[], runCases{caseN}, ...
            hws.getVariable('runName'), FASTInputFolder, ...
            hws.getVariable('OutputFolder'), Challenge, statsBase);

        % Compute cost from output
        J = simOut.CF;

    catch e

        warning(e.message)
        disp('  MLC_EVAL: Simulation returned error');
        J = MLC_params.badvalue;

        % Switch all of the workers back to their original folder.
        close_system(tmpSysMdl, 0);
        cd([MLC_params.problem_variables.RootOutputFolder '../'])
        try
            rmdir(tmpDir,'s');
        catch e
            warning(e.message)
        end
        
        clear mex;
        return
        
    end
    
    %% Switch all of the workers back to their original folder.
    
    close_system(tmpSysMdl, 0);
    cd([MLC_params.problem_variables.RootOutputFolder '../'])
    
    try
        rmdir(tmpDir,'s');
    catch e
        warning(e.message)
    end
    
    %% Plot figure if requested
    if exist('hFig','var') && ~isempty(hFig)
        fCostFunctionPlot(simOut.CF, simOut.CF_Comp, ...
            simOut.CF_Vars, {simOut.CF_Freq}, ...
            fMetricVars(runCases(caseN), Challenge), ...
            {'',sysMdl});
    end
    
catch e
    
    cd([MLC_params.problem_variables.RootOutputFolder '../'])
    warning(e.message)    
    J = MLC_params.badvalue;
    
end

clear mex;
end