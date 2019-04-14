%% toy2_run

restoredefaultpath;
clear all;close all;clc;
addpath('../../') % Directory containing `@MLC2` and others
addpath('../../MLC_tools') 

% Creation of the regression problem
mlc=MLC2('toy2_cfg'); % Creates a MLC object with default values that
                      % implements the simple regression problem.
                      
% Launch GP for 50 generations and return graphical output at end
mlc.go(50,1)