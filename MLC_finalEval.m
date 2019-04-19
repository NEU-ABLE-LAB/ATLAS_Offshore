%% MLC_finalEval Computes total cost function for individual

%% Initialization
% ref: Main.m
restoredefaultpath;
clear all;close all;clc;
addpath(genpath([pwd,'/_Functions']));  % Matlab functions for cost function and running cases - READ ONLY
addpath(genpath([pwd,'/_Controller'])); % Simulink model, where user scripts and models are placed
addpath(genpath([pwd,'/OpenMLC-Matlab-2'])); % OpenMLC classes and functions
addpath(pwd);

load('save_GP/20190417-2203/20190419_110244mlc_ae.mat')

MLC_params = mlc.parameters;
nSensors = MLC_params.sensors;
%% Select best individuals
nBest = 96;

goodIdxs = mlc.population(end).costs>0 & mlc.population(end).costs<1;
[~,goodIdxs] = sort(mlc.population(end).costs(goodIdxs));
disp(mlc.population(end).costs(goodIdxs)')
nBest = min(nBest, length(goodIdxs));

% Display best to be copied into `my_controller.m`
exprs = cell(nBest,1);
code2paste = cell(0);
code2paste{nBest} = '';

for bestN = 1:nBest
    
    exprs{bestN} = mlc.table.individuals(...
        mlc.population(end).individuals(goodIdxs(nBest))).formal;
    
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

%% Compute full cost for best individuals
parfor bestN = 1:nBest
    
    simOut = MLC_evalAll(...
        mlc.table.individuals(mlc.population(end).individuals(goodIdxs(nBest))),...
        mlc.parameters);
    
end