function [CF, CF_Comp, CF_Vars, CF_Freq, pMetrics, Metrics, FilesStats] = ...
    fCostFunctionFolders(folders, case_file, Challenge)
%
% INPUTS
%   - folders:  nx2 cell containing: Folder, Label
%               Folder is where the .outb files are, with slash at the end
%               Label is a label used in the legend when plotting is done

%% Load case and metrics init
[ Cases      ] = fReadCases(case_file)                      ; % DLC Cases
[ pMetrics   ] = fMetricVars(Cases, Challenge)              ; % Parameters for the metrics computation

%% Loop on results folder, compute cost function
nDirs = size(folders,1);
% allocating storage for each directory
Metrics         = cell(1,nDirs)                   ;
FilesStats      = cell(1,nDirs)                   ;
CF              = nan(1,nDirs)                    ;
CF_CompContribs = nan(nDirs,pMetrics.nComp)       ;
CF_VarContribs  = nan(nDirs,size(pMetrics.Vars,1));
CF_Freq         = cell(1,nDirs)                   ;
% loop on folders
for iDir = 1:nDirs
    folder = folders{iDir,1};
    if folder(end)~='/' && folder(end)~='\'; folder=[folder '/']; end
    % --- Compute folder stats and spectra - or load them from a file
    PreProFile= [folder 'PrePro_' Challenge '.mat'];
    %bForceRead = folders{iDir,3};
    if ~exist(PreProFile,'file')
        fprintf('>>> Computing stats for folder %s ...\n',folder);
        isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
        if isequal(folder, '_BaselineResults/') && ~isOctave % small hack here to save Baseline prepro.mat with Matlab
            [ FilesStats{iDir} ] = fComputeOutStats(folder, pMetrics, ...
                Cases, PreProFile);
        else
            [ FilesStats{iDir} ] = fComputeOutStats(folder, pMetrics, Cases);
        end
    else
        fprintf('>>> Reading preprocessed file %s ...\n',PreProFile);
        [ FilesStats{iDir} ] = load(PreProFile);
    end
    % --- Safety checks
    id =find(ismember(FilesStats{iDir}.ChanName, 'Wave1Elev'));
    if isequal(lower(Challenge),'onshore') && ~isempty(id)
        error('You are trying to evaluate results from the "Offshore" challenge, but you provided the option "Onshore" to the cost function method. Most likely you are running in the wrong challenge folder.')
    end
    if isequal(lower(Challenge),'offshore') && isempty(id)
        error('You are trying to evaluate results from the "Onshore" challenge, but you provided the option "Offshore" to the cost function method. Most likely you are running in the wrong challenge folder.')
    end

    % --- Evaluate metrics and cost function
    [ Metrics{iDir}    ] = fEvaluateMetrics(FilesStats{iDir}, pMetrics);

	% New, instead of using scaling file, we assume first dir is ref..
	if iDir==1
		xRef=Metrics{iDir}.Values;
	end
    [CF(iDir), CF_Comp(iDir,:), CF_Vars(iDir,:), CF_Freq{iDir}] = ...
        fCostFunction(Metrics{iDir}.Values, xRef, pMetrics);

    % --- Safety check
    if length(FilesStats{iDir}.OutFiles)~=length(Cases.Names);
        warning('Only %d/%d files found in %s.',length(FilesStats{iDir}.OutFiles), length(Cases.Names), folder); 
    end
end
