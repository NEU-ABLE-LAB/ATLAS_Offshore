%% MainMLC_FinalEval
restoredefaultpath;
clear all;
clc;
dbstop if error

%% Initialization
% ref: Main.m
addpath(genpath([pwd,'/_Functions']));  % Matlab functions for cost function and running cases - READ ONLY
addpath(genpath([pwd,'/_Controller'])); % Simulink model, where user scripts and models are placed
addpath(genpath([pwd,'/OpenMLC-Matlab-2'])); % OpenMLC classes and functions
addpath(pwd);

% Run compute the costs of the MLC object
MLC_finalEval('G:\Team Drives\ABLE_ATLAS_OffShore\save_GP\20190426-0056\20190428_132730mlc_ae.mat');