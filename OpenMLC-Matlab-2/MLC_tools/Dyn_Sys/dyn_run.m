%% dyn_run

restoredefaultpath;
clear all;close all;clc;
addpath('../../') % Directory containing `@MLC2` and others
addpath('../../MLC_tools') 

% Creation of the regression problem
mlc=MLC2('dyn_sys'); % Creates a MLC object with default values that
                      % implements the simple regression problem.
                      
% Launch GP for 50 generations and displays the best individual if
% implemented in the evaluation function at the end of each generation
% evaluation
mlc.go(50,1)

% Return the best individual, its cost function value and other statistics:
mlc.show_best
