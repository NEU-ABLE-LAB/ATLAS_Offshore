%% unidim_DS_run
% MLC for control design example of a noise-free, linear, one-
% dimensional ordinary differential equation, arguably the most simple
% example MLC for control

restoredefaultpath;
clear all;close all;clc;
addpath('../../') % Directory containing `@MLC2` and others
addpath('../../MLC_tools') 

% Creation of the regression problem
mlc=MLC2('unidim_DS_script'); % Creates a MLC object with default values that
                              % implements the simple regression problem.
                             
% Launch the problema for 15 generations and show graphical output after
% each generation
mlc.go(15,1)

% analyze the whole evolution process
mlc.show_convergence