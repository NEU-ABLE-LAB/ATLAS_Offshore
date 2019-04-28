%% MainMLC_FinalEval Computes total cost function for individual
restoredefaultpath;
clear all
clc
dbstop if error

%% Request MLC mat file
fName = input('Please enter the path to the MLC mat file\n','s');
assert(exist(fName,'file')>0, ...
    'MLC mat file does not exist on path');

%% Initialization
% ref: Main.m
addpath(genpath([pwd,'/_Functions']));  % Matlab functions for cost function and running cases - READ ONLY
addpath(genpath([pwd,'/_Controller'])); % Simulink model, where user scripts and models are placed
addpath(genpath([pwd,'/OpenMLC-Matlab-2'])); % OpenMLC classes and functions
addpath(pwd);

% File defining the cases that are run
case_file = '_Inputs/_inputs/Cases.csv'; 

%% Load the MLC object
mlc = load(fName,'mlc');
mlc = mlc.mlc;

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

%% Extract MLC problem variables specified when calling `MLC_cfg()`

% Design cases
runCases = MLC_params.problem_variables.runCases;

% Name of challenge
Challenge = MLC_params.problem_variables.Challenge;

% Statistics from baseline controller
statsBase = MLC_params.problem_variables.statsBase;

%% Select best individuals
nBest = 8;
totalGens = length(mlc.population);
GenNBack = 1; % Indexed so 1 is the last generation 
genN = @(tmp_nGensBack)(totalGens - tmp_nGensBack - 1);

goodIdxs = find(...
    (mlc.population(genN(GenNBack)).costs > 0) & ...
    (mlc.population(genN(GenNBack)).costs < 1) );

disp(mlc.population(genN(GenNBack)).costs(goodIdxs)')
fprintf('%i better than threshold individuals\n', length(goodIdxs));
nBest = min(nBest, length(goodIdxs));

%% Display characteristics of best individuals

% Extract control logic
exprs = cell(nBest,1);
fcnText = cell(nBest,1);
for bestN = 1:nBest
    
    [exprs{bestN}, fcnText{bestN}] = MLC_exprs( mlc.table.individuals( ...
            mlc.population(genN(GenNBack)).individuals(goodIdxs(bestN))...
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

nGensBack = 1;
nCases = numel(MLC_params.problem_variables.runCases);
simOut = cell(nBest,nCases,nGensBack);

% Get indivudals to test
%   Doing so now minimizes parfor overhead
idvs = cell(nBest,nGensBack);
for idx = 1:(nBest*nGensBack)
    
    [bestN, GenNBack] = ind2sub([nBest, nGensBack], idx); 
    
    idvs{bestN,GenNBack} = mlc.table.individuals( ...
        mlc.population(genN(GenNBack)).individuals( ...
            goodIdxs(bestN)));
        
end

% Create parfor progress monitor
pp = gcp(); 
ppm = ParforProgMon(...
    sprintf('MLC_finalEval - %i idvs w/ %i cases @ %s: ', ...
        nBest, nCases, datestr(now,'HH:MM')), ...
    nBest*nCases, 1,1200,160);

% Evaluate all the individuals, cases, and generations
parfor idx = 1:(nBest*nCases*nGensBack)
    
    [bestN, caseN, GenNBack] = ind2sub([nBest, nCases, nGensBack], idx); 

    % Comptue cost of individual 
    [~, simOut{idx}] = MLC_eval(...
        idvs{bestN,GenNBack}, MLC_params, [], [], caseN); %#ok<PFBNS>
    
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

CF(nBest,nGensBack) = CF;

for GenNBack = 1:nGensBack
    for bestN = 1:nBest
        % Check for bad simulations
        %   Missing simulations
        %   Bad value simulations
        if any(cellfun( @isempty, simOut(bestN,:,GenNBack) )) || ... 
                any(cellfun(@(x)(x.CF >= MLC_params.badvalue), ...
                    simOut(bestN,:,GenNBack)))

            CF(bestN,GenNBack).CF = MLC_params.badvalue;
            CF(bestN,GenNBack).CF_Comp = MLC_params.badvalue;
            CF(bestN,GenNBack).CF_Vars = MLC_params.badvalue;
            CF(bestN,GenNBack).CF_Freq = MLC_params.badvalue;

        else
            try
                % Compute for good individuals
                [CF(bestN,GenNBack).CF, ...
                    CF(bestN,GenNBack).CF_Comp, ...
                    CF(bestN,GenNBack).CF_Vars, ...
                    CF(bestN,GenNBack).CF_Freq, ...
                    ~, ~, ~] = fCostFunctionSimOut(...
                        simOut(bestN,:,GenNBack), ...
                        Challenge, ...
                        fEvaluateMetrics(statsBase, ...
                            fMetricVars(runCases, Challenge)));
            catch
                % Assume bad individual if something is wrong
                CF(bestN,GenNBack).CF = MLC_params.badvalue;
                CF(bestN,GenNBack).CF_Comp = MLC_params.badvalue;
                CF(bestN,GenNBack).CF_Vars = MLC_params.badvalue;
                CF(bestN,GenNBack).CF_Freq = MLC_params.badvalue;
            end
        end
    end
end

%% Plot aggregate metrics
GenNBack = 1;

pMetrics = fMetricVars(...
    fReadCases(case_file), Challenge);

folders = cell(nBest,2);
folders(:) = '';
folders(:,2) = arrayfun(@(tmp_idv)( sprintf( 'Gen %i - Idv %i', ...
    genN(GenNBack),tmp_idv)),goodIdxs(1:nBest),...
    'UniformOutput',false)';

fCostFunctionPlot(...
    [CF.CF], ...
    reshape([CF.CF_Comp],length(CF(1).CF_Comp),nBest)', ...
    reshape([CF.CF_Vars],nCases,nBest)', ...
    [CF.CF_Freq], ...
    pMetrics, folders)

%% Save results back to the file
simOutSmall = cellfun(@(x)(rmfield(x,'Channels')), simOut);
save(fName,'mlc','simOutSmall')