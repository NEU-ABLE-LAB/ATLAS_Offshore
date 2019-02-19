function fRunFAST(FASTInputFolder, SimulinkModelFile, hSetControllerParameter, OutputFolder)
    % Script to run FAST simulations using a simulink model. 
    % The simulations are run for each .fst file found in the FASTInputFolder given as input.
    %
    % INPUTS:
    %   FASTInputFolder        : FASTInputFolder where the .fst files are
    %   SimulinkModelFile      : path to the .mdl file to use
    %   hSetControllerParameter: handle to a function that sets additional controller parameter to the structure `Parameter`
    %                            The structure `Parameter` is the only variable accessible to the Simulink model (global)
    %
    % OPTIONAL INPUTS:
    %   OutputFolder: FASTInputFolder where the output files should be moved to . Default: current folder
    % 
    % EXAMPLE CALL:
    %   fRunFAST('_Inputs\LoadCases\', '_Controller\NREL5MW_NREL_v1_OpenFAST.mdl')
    %
    global Parameter

    %--- Optional arguments
    if ~exist('OutputFolder','var'); OutputFolder=[]; end;

    %--- Checks
    if ~exist(FASTInputFolder ,'dir');   error('FASTInputFolder not found %s',FASTInputFolder); end;
    if ~exist(SimulinkModelFile,'file'); error('Model not found %s',SimulinkModelFile); end;
    if FASTInputFolder(end)~='/' || FASTInputFolder(end)~='\'; FASTInputFolder=[FASTInputFolder '/']; end


    InpFiles = dir([FASTInputFolder '*.fst']);
    if length(InpFiles)<=0; error('No .fst files found in %s',FASTInputFolder); end;

    % --- Clean up of FASTInputFolder
    OutFiles = dir([FASTInputFolder '*.outb']);
    if length(OutFiles)>0; 
        warning('Some output files are found in %s. Deleting them...',FASTInputFolder);
        warning off
        delete([FASTInputFolder '*.outb'])
        delete([FASTInputFolder '*.sum' ])
        warning on
    end



    % --- Loop on .fst file and running simulations
    warning off; % FAST shows some unnecessary warnings
    nInpFiles = length(InpFiles);
    ErrorList={};
    for i=1:nInpFiles
        FileName  = [FASTInputFolder InpFiles(i).name];
            fprintf('\n');
            fprintf('-----------------------------------------------------------------------------\n');
            fprintf('>>> %2d/%2d - Simulating: %s \n',i,nInpFiles,FileName);
            fprintf('-----------------------------------------------------------------------------\n');
        % Setting controller parameters - constants and specific to a given simulation.
        Parameter = fSetSimulinkParameters(FileName, hSetControllerParameter);   
        try
            sim(SimulinkModelFile);
        catch exception
            rethrow(exception); % FOR NOW RETHROW!!!
            disp(exception.message)
            ErrorList{end+1}=sprintf('Simulation %s failed: %s', Parameter.FASTfile, exception.message);
            FAST_SFunc(0,0,0,0);% reset sFunction
        end
        clear mex
    end % loop on files
    warning on

    % --- Moving outputs
    OutFiles = dir([FASTInputFolder '*.outb']);
    nOutFiles = length(OutFiles);
    fprintf('\n');
    fprintf('-----------------------------------------------------------------------------\n');
    fprintf('>>> Output files found: %2d/%2d \n',nOutFiles,nInpFiles);
    fprintf('-----------------------------------------------------------------------------\n');
    if ~isempty(OutputFolder) && nOutFiles>0;  
        if ~exist(OutputFolder,'dir');
            %warning('The outputFolder %s does not exit. Creating it.',OutputFolder);
            mkdir(OutputFolder);
        end
        fprintf('Moving %d/%d out files to %s...\n',nOutFiles,nInpFiles,OutputFolder);
        movefile([FASTInputFolder '*.outb'],OutputFolder);
    end
    if nOutFiles~=nInpFiles
        error('Some output files are missing. Please troubleshoot the simulations.')
    end


end

