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
    exprs = MLC_exprs(ind.formal, MLC_params);
    
    % Create string to write to the script file
    fcnText = sprintf('function y = fcn(u) \n');
	fcnText = sprintf('%sy = [', fcnText);
	for exprN = 1:length(exprs)

        if exprN ~= 1
            fcnText = sprintf('%s\t', ...
                fcnText);
        end
        
		fcnText = sprintf('%s\t%s', ...
            fcnText, exprs{exprN});
        
        if exprN ~= length(exprs)
            fcnText = sprintf('%s; \n ',...
                fcnText);
        end

	end	
	fcnText = sprintf('%s];', fcnText);

    % Get `Fcn` block handle
    hb = find(slroot, '-isa', 'Stateflow.EMChart', 'Path', ...
        sprintf('%s/MLC_IPC/control_law', tmpSysMdl) );

	% Insert the expressions into the model    	
	hb.Script = fcnText;

    %% Run simulation

    % Randomly choose a design load case
    caseN = randi(length(runCases));
                
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
    
catch e
    
    cd([MLC_params.problem_variables.RootOutputFolder '../'])
    warning(e.message)    
    J = MLC_params.badvalue;
    
end

clear mex;
end