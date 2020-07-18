%% MainMLC_FinalEval Computes total cost function for individual
restoredefaultpath;
clear all
clc
dbstop if error

% Parameters
nBest = 8;
nGensBack = 4;

%% Request MLC mat file
[fName,fPath] = uigetfile;
fName = fullfile(fPath,fName);

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

MLC_params = mlc.parameters;

%% Extract MLC problem variables specified when calling `MLC_cfg()`

% Design cases
runCases = MLC_params.problem_variables.runCases;

% Name of challenge
Challenge = MLC_params.problem_variables.Challenge;

% Statistics from baseline controller
statsBase = MLC_params.problem_variables.statsBase;

%% Select best individuals

totalGens = length(mlc.population);
genNBack = 1; % Indexed so 1 is the last generation 
genN = @(tmp_nGensBack)(totalGens - tmp_nGensBack + 1);

goodIdxs = find(...
    (mlc.population(genN(genNBack)).costs > 0) & ...
    (mlc.population(genN(genNBack)).costs < 1) );

disp(mlc.population(genN(genNBack)).costs(goodIdxs)')
fprintf('%i better than threshold individuals\n', length(goodIdxs));
nBest = min(nBest, length(goodIdxs));

%% Display characteristics of best individuals

% Plot convergence
mlc.show_convergence
set(gca,'yscale','linear')
ylim([min(cellfun(@min,{mlc.population.costs})) 1.1])
xticks(gca, 1:length(mlc.population));
xticklabels( gca, cellfun( @(x,y)(sprintf('%s:%i',x,y)), ...
    xticklabels(gca), {mlc.population.caseN}', 'UniformOutput',false))
xtickangle(gca,90)

% Extract control logic
exprs = cell(length(goodIdxs),1);
fcnText = cell(length(goodIdxs),1);
for bestN = 1:length(goodIdxs)
    
    [exprs{bestN}, fcnText{bestN}] = MLC_exprs( mlc.table.individuals( ...
            mlc.population(genN(genNBack)).individuals(goodIdxs(bestN))...
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
figure('windowstyle','docked')
bar(mean(sensorIdxs));
xticks(1:length(MLC_params.problem_variables.sensorIdxs));
xticklabels(MLC_params.problem_variables.sensorNames)
xtickangle(90)

%% Compute full cost for best individuals

nCases = numel(MLC_params.problem_variables.runCases);
simOut = cell(nBest,nCases,nGensBack);

% Get indivudals to test
%   Doing so now minimizes parfor overhead
idvs = cell(nBest,nGensBack);
for idx = 1:(nBest*nGensBack)
    
    [bestN, genNBack] = ind2sub([nBest, nGensBack], idx); 
    
    idvs{bestN,genNBack} = mlc.table.individuals( ...
        mlc.population(genN(genNBack)).individuals( ...
            goodIdxs(bestN)));
        
end

% Create parfor progress monitor
pp = gcp(); 
ppm = ParforProgMon(...
    sprintf('MLC_finalEval - %i idvs w/ %i cases & %i gens@ %s: ', ...
        nBest, nCases, nGensBack, datestr(now,'HH:MM')), ...
    nBest*nCases*nGensBack, 1,1200,160);

% Evaluate all the individuals, cases, and generations
parfor idx = 1:(nBest*nCases*nGensBack)
    
    [bestN, caseN, genNBack] = ind2sub([nBest, nCases, nGensBack], idx); 

    % Comptue cost of individual 
    [~, simOut{idx}] = MLC_eval(...
        idvs{bestN,genNBack}, MLC_params, [], [], caseN); %#ok<PFBNS>

    % Close all Simulink system windows unconditionally
    bdclose('all')
    % Clean up worker repositories
    Simulink.sdi.cleanupWorkerResources
    % https://www.mathworks.com/matlabcentral/answers/385898-parsim-function-consumes-lot-of-memory-how-to-clear-temporary-matlab-files
    sdi.Repository.clearRepositoryFile
    
    ppm.increment(); %#ok<PFBNS>
    
end

%% Compute aggregate evaluation of individual across all cases
pMetrics = fMetricVars(...
    fReadCases(case_file), Challenge);

CF = struct('CF',-1, 'CF_Comp',MLC_params.badvalue, ...
    'CF_Vars',MLC_params.badvalue, 'CF_Freq',MLC_params.badvalue);

CF(nBest,nGensBack) = CF;

for genNBack = 1:nGensBack
    for bestN = 1:nBest
        % Check for bad simulations
        %   Missing simulations
        %   Bad value simulations
        if any(cellfun( @isempty, simOut(bestN,:,genNBack) )) || ... 
                any(cellfun(@(x)(x.CF >= MLC_params.badvalue), ...
                    simOut(bestN,:,genNBack)))

            CF(bestN,genNBack).CF = MLC_params.badvalue;
            
            CF(bestN,genNBack).CF_Comp = MLC_params.badvalue * ...
                ones(1,length(pMetrics.uComponents));
            
            CF(bestN,genNBack).CF_Vars = MLC_params.badvalue * ...
                ones(1,length(pMetrics.VarsWeights));
            
            CF(bestN,genNBack).CF_Freq = struct( ...
                'MRi',nan(12,10), 'MAbs',nan(12,10));

        else
            try
                % Compute for good individuals
                [CF(bestN,genNBack).CF, ...
                    CF(bestN,genNBack).CF_Comp, ...
                    CF(bestN,genNBack).CF_Vars, ...
                    CF(bestN,genNBack).CF_Freq, ...
                    ~, ~, ~] = fCostFunctionSimOut(...
                        simOut(bestN,:,genNBack), ...
                        Challenge, ...
                        fEvaluateMetrics(statsBase, ...
                            fMetricVars(runCases, Challenge)));
            catch
                % Assume bad individual if something is wrong
                CF(bestN,genNBack).CF = MLC_params.badvalue;

                CF(bestN,genNBack).CF_Comp = MLC_params.badvalue * ...
                    ones(1,length(pMetrics.uComponents));

                CF(bestN,genNBack).CF_Vars = MLC_params.badvalue * ...
                    ones(1,length(pMetrics.VarsWeights));

                CF(bestN,genNBack).CF_Freq = struct( ...
                    'MRi',nan(12,10), 'MAbs',nan(12,10));
            end
        end
    end
end

%% Plot aggregate metrics
    
for genNBack = 1:nGensBack

    folders = cell(nBest,2);
    folders(:) = '';
    folders(:,2) = arrayfun(@(tmp_idv)( sprintf( 'Gen %i - Idv %i', ...
        genN(genNBack),tmp_idv)),goodIdxs(1:nBest),...
        'UniformOutput',false)';
    
    % Extract costs
    tmp_CF = [CF(:,genNBack).CF];
    tmp_CF_Comp = {CF(:,genNBack).CF_Comp};
    for k = 1:length(tmp_CF_Comp)
        if length(tmp_CF_Comp{k})==1
            tmp_CF_Comp{k} = ones(1,length(pMetrics.uComponents)) * ...
                MLC_params.badvalue;
        end
    end
    tmp_CF_Comp = cell2mat(tmp_CF_Comp');
    tmp_CF_Vars = {CF(:,genNBack).CF_Vars};
    for k = 1:length(tmp_CF_Vars)
        if length(tmp_CF_Vars{k})==1
            tmp_CF_Vars{k} = ones(1,12) * ...
                MLC_params.badvalue;
        end
    end
    tmp_CF_Vars = cell2mat(tmp_CF_Vars');
    tmp_CF_Freq = cell(size(CF(:,genNBack)));
    for k = 1:length(tmp_CF_Freq)
        if length(tmp_CF_Freq{k})==1
            tmp_CF_Freq{k} = struct('MRi',nan(12,10),'MAbs',nan(12,10));
        else
            tmp_CF_Freq{k} = CF(k,genNBack).CF_Freq;
        end
    end
    
    fCostFunctionPlot(...
        tmp_CF, ...
        tmp_CF_Comp, ...
        tmp_CF_Vars, ...
        tmp_CF_Freq, ...
        pMetrics, folders,'absVar')
    
    ylim([0 2]);
    
end

%% Plot Comparison of each case
for genNBack = 1:nGensBack
    
    figure('windowstyle','docked')
    
    tmp_CF = simOut(:,:,genNBack);
    
    for n = 1:numel(tmp_CF)
        if isstruct(tmp_CF{n})
            tmp_CF{n} = tmp_CF{n}.CF;
        else
            tmp_CF{n} = MLC_params.badvalue;
        end
    end
    tmp_CF = cell2mat(tmp_CF);
    
    bar(tmp_CF')
    
    title(sprintf('Performance on Cases: Gen %i from Case %', ...
        genN(genNBack), ...
        mlc.population(genN(genNBack)-1).caseN));
    xlabel('Case #')
    ylim([0 2])
end

%% Print the best control logic

% Find the best individual
[~,idx] = min([CF.CF]);
[bestN,genNBack] = ind2sub(size(CF), idx);
idvN = mlc.population(genN(genNBack)).individuals(bestN);
expr = mlc.table.individuals(idvN).formal;



%% Save results back to the file
simOutSmall = simOut;
for k = 1:numel(simOutSmall)
    if isstruct(simOutSmall{k}) && isfield(simOutSmall{k},'Channels')
        simOutSmall{k} = rmfield(simOutSmall{k},'Channels');
    end
end
save(fName,'mlc','simOutSmall','CF')