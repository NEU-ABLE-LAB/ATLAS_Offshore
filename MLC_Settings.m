   %% MLC_Settings
% create a MLC object and save it to the specified folder

restoredefaultpath;
clear all; close all; clc;
dbstop if error

%% Initialization
addpath(pwd)
addpath(genpath([pwd,'/OpenMLC-Matlab-2'])); % OpenMLC classes and functions
addpath(genpath([pwd,'/MLC_Problemfunctions'])); % functions related to the turbine problem 
addpath(genpath([pwd,'/ParforProgMon'])); % Parfor progress monitor 

%% Configure Problem Parameters

%--- General Parameters
% Problem based parameters can be changed within the config function below:
problem_variables = fConfigProblemParams();

%% Configure MLC Parameters

%--- General Parameters
% MLC parameters can be changed within the config function below:
MLC_Params = fConfigMLCParams(problem_variables);

%% Parameters that can change

%--- Path Info

%--- Path to FAST_Par
    MLC_Params.problem_variables.FastPath = 'D:\Documents\GitHub\ATLAS_FAST-par';   % Fast_Par
    MLC_Params.problem_variables.MLCPath = pwd;

%--- Controler Setup
    MLC_Params.problem_variables.nStates = 3;                % number of allowable states to the controler

%--- Generations and Population
    MLC_Params.size = 100;                 %*(num)[1000]$N_i$ Population size
    Ngens = 50;                            % number of generations to evaluate and evolve

    MLC_Params.ev_again_best = 0;          %*(bool)[0] Should elite individuals be reevaluated
    MLC_Params.ev_again_nb = 1;            % ?(num)[5] Number off best individuals to reevaluate. Should probably be similar to `elitism`.

    MLC_Params.elitism = 3;                %*(num)[10]$N_e$ Number of best individuals to carry over to next generation
    MLC_Params.champions = 2; % (num)  Number of champion individuals for each load case    
    
%--- Evaluation
    MLC_Params.evaluation_function=...      %*(expr)['toy_problem'] Cost function name. 
        'MLC_eval';                         %   `J=evalFun(ind,mlc_parameters,i,fig)`
    MLC_Params.preev_function=...           % (expr)[''] A Matlab expression to be evaluated with `eval()` to pre-evalute an individual
        'MLC_preeval';                      %   Expression should return `1` if pre-evaluation identified a valid individual
                                    
    MLC_Params.problem_variables.eval_type = 'case_difficulty';        % 'ind_random'      = Evaluate Each individual using a unique random load case 
                                                                  % 'case_difficulty' = Evaluate all individuals using the load case with the highest dificulty 

%% other dependant values
% For use in case dificulty
MLC_Params.problem_variables.caseDifficulty = ones(1,MLC_Params.nCases) * MLC_Params.badvalue; 

MLC_Params.controls= ...            %*(num)[1]$N_b$ Number of controls             
    3 + MLC_Params.problem_variables.nStates;
MLC_Params.sensors=...              %*(num)[1]$N_s$ Number of sensors               outlist sensors + states
    MLC_Params.problem_variables.nSensors + MLC_Params.problem_variables.nStates;

for j = 1 : MLC_Params.problem_variables.nStates
   %for each state append the input number
   MLC_Params.problem_variables.sensorIdxs(MLC_Params.problem_variables.nSensors + j) = length(fieldnames(MLC_Params.problem_variables.outListIdx)) + j;
   %allows MLC2FAST to correctly identify state variables 
end
%% Machine Learning Control

% Create a MLC object
mlc=MLC2(MLC_Params); 

% save MLC Object
fname = [mlc.parameters.savedir,'\',datestr(now,'YYYYmmDD-HHMMSS'),'_MLC_TEST_SETTINGS'];
save(fname,'mlc')
                      
% Launch GP 
 mlc.go(Ngens,3)