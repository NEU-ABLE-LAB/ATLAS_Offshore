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

%% Select best individuals
nBest = 1;

goodIdxs = mlc.population(end).costs>0 & mlc.population(end).costs<1;
[~,goodIdxs] = sort(mlc.population(end).costs(goodIdxs));
disp(mlc.population(end).costs(goodIdxs)')

%% Compute full cost for best individuals
for bestN = 1:nBest
    
    simOut = MLC_evalAll(...
        mlc.table.individuals(mlc.population(end).individuals(goodIdxs(nBest))),...
        mlc.parameters);
    
end