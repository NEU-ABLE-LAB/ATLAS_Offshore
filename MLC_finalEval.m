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

load('save_GP/20190426-0056/20190427_155043mlc_ae.mat')
mlc.parameters.saveincomplete = 0;

mlc.show_convergence

MLC_params = mlc.parameters;
nSensors = MLC_params.sensors;

%% Select best individuals
nBest = 48;
genN = length(mlc.population) - 0;

goodIdxs = (mlc.population(genN).costs>0) & (mlc.population(genN).costs<1);
[~,goodIdxs] = sort(mlc.population(genN).costs(goodIdxs));
disp(mlc.population(genN).costs(goodIdxs)')
fprintf('%i better than threshold individuals\n', length(goodIdxs));
nBest = min(nBest, length(goodIdxs));

% Display best to be copied into `my_controller.m`
exprs = cell(nBest,1);
code2paste = cell(0);
code2paste{nBest,1} = '';

for bestN = 1:nBest
    
    exprs{bestN} = mlc.table.individuals(...
        mlc.population(genN).individuals(goodIdxs(bestN))).formal;
    
    for exprN = 1:length(exprs{bestN})
        
        for sensorN = 1:nSensors

            % Replace senor name with indexed input signal
            exprs{bestN}{exprN} = regexprep(exprs{bestN}{exprN}, ...
                sprintf('(^|\\W)S%d(?=\\W|$)',sensorN-1),...
                sprintf('$1u(%d)',...
                    MLC_params.problem_variables.sensorIdxs(sensorN)));

            % Replace `.*` with `*`
            %   Since the `fcn` Simulink blocks don't support `.*`
            exprs{bestN}{exprN} = strrep(...
                exprs{bestN}{exprN}, '.*', '*');        
        end
        
        % Formulate the line for use in `my_controller.m`        
        code2paste{bestN} = sprintf('%sy(%d)=%s;\r\n', code2paste{bestN},...
            exprN, exprs{bestN}{exprN});
        
    end
end

outListNames = fieldnames(MLC_params.problem_variables.outListIdx);
outListLen = length(outListNames);
outListIdxs = regexp(code2paste,'u\((\d*)\)','tokens');
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
bar(mean(sensorIdxs));
xticks(1:length(MLC_params.problem_variables.sensorIdxs));
xticklabels(MLC_params.problem_variables.sensorNames)
xtickangle(90)

%% Compute full cost for best individuals

numSims = numel(MLC_params.problem_variables.runCases);
simOut = cell(numSims,1);
J = -ones(numSims,1);

pp = gcp();
ppm = ParforProgMon(...
    sprintf('MLC_finalEval - %i idvs w/ %i cases @ %s: ', ...
        nBest, numSims, datestr(now,'HH:MM')), ...
    nBest*numSims, 1,1200,160);

parfor bestN = 1:nBest
    
    [J(bestN), simOut{bestN}] = MLC_evalAll(...
        mlc.table.individuals(...
            mlc.population(end).individuals(goodIdxs(bestN))),...
        mlc.parameters, [], [], ppm);
    
    % Close all Simulink system windows unconditionally
    bdclose('all')
    % Clean up worker repositories
    Simulink.sdi.cleanupWorkerResources
    % https://www.mathworks.com/matlabcentral/answers/385898-parsim-function-consumes-lot-of-memory-how-to-clear-temporary-matlab-files
    sdi.Repository.clearRepositoryFile
    
end