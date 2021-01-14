%% MLC_eval Evaluates the fitness of an individual for a single case
%
%   INPUTS
%       ind - Current mlc.individuals
%       MLC_params - mlc.parameters
%       caseN - load case to run
%
function [CF,SimOut,Costs] = MLC_PostEval(fcnText, MLCParameters, FastPath, MLCPath)
    [~,Sims] = size(fcnText);

    %Run sims
    cd(FastPath)
    
    Main_Par_MLC_post
    
    cd(MLCPath)    
    restoredefaultpath;
    addpath(pwd)
    addpath(genpath([pwd,'/OpenMLC-Matlab-2'])); % OpenMLC classes and functions
    addpath(genpath([pwd,'/MLC_Problemfunctions'])); % functions related to the turbine problem

    
    CF = CF;
    SimOut = simOut;
    Costs = J
    
    
end