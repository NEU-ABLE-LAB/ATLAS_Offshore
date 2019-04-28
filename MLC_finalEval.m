%% MLC_finalEval Computes total cost function for individual
restoredefaultpath;
clear all;close all;clc;
dbstop if error

%% Initialization
% ref: Main.m
addpath(genpath([pwd,'/_Functions']));  % Matlab functions for cost function and running cases - READ ONLY
addpath(genpath([pwd,'/_Controller'])); % Simulink model, where user scripts and models are placed
addpath(genpath([pwd,'/OpenMLC-Matlab-2'])); % OpenMLC classes and functions
addpath(pwd);

load('G:\Team Drives\ABLE_ATLAS_OffShore\save_GP\20190426-0056_2\20190428_164853mlc_ae.mat')

% Update parameters for this analysis & machine
mlc.parameters.saveincomplete = 0;
mlc.parameters.problem_variables.FASTInputFolder = ...
    [pwd '/_Inputs/LoadCases/'] ; % directory of the FAST input files are (e.g. .fst files)
mlc.parameters.problem_variables.RootOutputFolder = ...
    [pwd '/_Outputs/']         ; % Folder where the current simulation outputs will be placed
mlc.parameters.problem_variables.ctrlFolder = ...
    [pwd '/_Controller/']      ; % Location of Simulink files

mlc.show_convergence

MLC_params = mlc.parameters;
nSensors = MLC_params.sensors;

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

%% Select best individuals
nBest = 8;
genN = length(mlc.population) - 0;

goodIdxs = find(...
    (mlc.population(genN).costs > 0) & ...
    (mlc.population(genN).costs < 1) );

disp(mlc.population(genN).costs(goodIdxs)')
fprintf('%i better than threshold individuals\n', length(goodIdxs));
nBest = min(nBest, length(goodIdxs));

%% Display characteristics of best individuals

% Extract control logic
exprs = cell(nBest,1);
fcnText = cell(nBest,1);
for bestN = 1:nBest
    
    [exprs{bestN}, fcnText{bestN}] = MLC_exprs( mlc.table.individuals( ...
            mlc.population(genN).individuals(goodIdxs(bestN))...
        ).formal, MLC_params);
    
end

% Calculate how often each sensor is used
outListNames = fieldnames(MLC_params.problem_variables.outListIdx);
outListLen = length(outListNames);
outListIdxs = regexp(fcnText,'u\((\d*)\)','tokens');
for k = 1:length(outListIdxs)
    outListIdxs{k} = cellfun(@(sensorIdx)str2double(sensorIdx{1}),outListIdxs{k});
    outListIdxs{k} = full(sparse(...
        ones(size(outListIdxs{k})),...
        outListIdxs{k},...
        ones(size(outListIdxs{k})),...
        1, outListLen));
end
outListIdxs = cell2mat(outListIdxs);
sensorIdxs = outListIdxs(:,MLC_params.problem_variables.sensorIdxs);

% Plot sensor use statistics
figure
bar(mean(sensorIdxs));
xticks(1:length(MLC_params.problem_variables.sensorIdxs));
xticklabels(MLC_params.problem_variables.sensorNames)
xtickangle(90)

%% Compute full cost for best individuals

nGens = 1;
nCases = numel(MLC_params.problem_variables.runCases);
simOut = cell(nBest,nCases,nGens);

% Get indivudals to test
%   Doing so now minimizes parfor overhead
idvs = cell(nBest,nGens);
for idx = 1:(nBest*nGens)
    
    [bestN, genN] = ind2sub([nBest, nGens], idx); 
    
    idvs{bestN,genN} = mlc.table.individuals( ...
        mlc.population(genN).individuals( ...
            goodIdxs(bestN)));
        
end

% Create parfor progress monitor
pp = gcp();
ppm = ParforProgMon(...
    sprintf('MLC_finalEval - %i idvs w/ %i cases @ %s: ', ...
        nBest, nCases, datestr(now,'HH:MM')), ...
    nBest*nCases, 1,1200,160);

% Evaluate all the individuals, cases, and generations
parfor idx = 1:(nBest*nCases*nGens)
    
    [bestN, caseN, genN] = ind2sub([nBest, nCases, nGens], idx); 

    % Comptue cost of individual 
    [J(idx), simOut{idx}] = MLC_eval(...
        idvs{bestN,genN}, MLC_params, [], [], caseN);
    
    % Close all Simulink system windows unconditionally
    bdclose('all')
    % Clean up worker repositories
    Simulink.sdi.cleanupWorkerResources
    % https://www.mathworks.com/matlabcentral/answers/385898-parsim-function-consumes-lot-of-memory-how-to-clear-temporary-matlab-files
    sdi.Repository.clearRepositoryFile
    
    ppm.increment(); %#ok<PFBNS>
    
end

%% Compute aggregate evaluation of individual across all cases

CF = struct('CF',-1, 'CF_Comp',MLC_params.badvalue, ...
    'CF_Vars',MLC_params.badvalue, 'CF_Freq',MLC_params.badvalue);

CF(nBest,nGens) = CF;
for genN = 1:nGens
    for bestN = 1:nBest
        % Check for bad simulations
        %   Missing simulations
        %   Bad value simulations
        if any(cellfun( @isempty, simOut(bestN,:,genN) )) || ... 
                any(cellfun(@(x)(x.CF >= MLC_params.badvalue), ...
                    simOut(bestN,:,genN)))

            CF(bestN,genN).CF = MLC_params.badvalue;
            CF(bestN,genN).CF_Comp = MLC_params.badvalue;
            CF(bestN,genN).CF_Vars = MLC_params.badvalue;
            CF(bestN,genN).CF_Freq = MLC_params.badvalue;

        else
            try
                % Compute for good individuals
                [CF(bestN,genN).CF, ...
                    CF(bestN,genN).CF_Comp, ...
                    CF(bestN,genN).CF_Vars, ...
                    CF(bestN,genN).CF_Freq, ...
                    ~, ~, ~] = ...
                        fCostFunctionSimOut(simOut(bestN,:,genN), ...
                            Challenge, ...
                            fEvaluateMetrics(statsBase, ...
                                fMetricVars(runCases, Challenge)));
            catch
                % Assume bad individual if something is wrong
                CF(bestN,genN).CF = MLC_params.badvalue;
                CF(bestN,genN).CF_Comp = MLC_params.badvalue;
                CF(bestN,genN).CF_Vars = MLC_params.badvalue;
                CF(bestN,genN).CF_Freq = MLC_params.badvalue;
            end
        end
    end
end
