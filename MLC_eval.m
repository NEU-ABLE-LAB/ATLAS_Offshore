%% MLC_eval Evaluates the fitness of an individual for a single case
%
%   INPUTS
%       ind - Current mlc.individuals
%       MLC_params - mlc.parameters
%       caseN - load case to run
%
function [costs, caseNout] = MLC_eval(ind, MLC_params,MLC_Runcase)
    
    fcnText = cell(1, length(ind));
    costs = zeros(1, length(ind));
    caseNout = cell(1, length(ind));
    
    for ii = 1 : length(ind)
        [~,fcnText{ii}] = MLC_MLC2Fast(ind(ii).formal, MLC_params);
    end
    
    cd(MLC_params.problem_variables.FastPath)
    
    Main_Par_MLC
    
    cd(MLC_params.problem_variables.MLCPath)    
    restoredefaultpath;
    addpath(pwd)
    addpath(genpath([pwd,'/OpenMLC-Matlab-2'])); % OpenMLC classes and functions
    addpath(genpath([pwd,'/MLC_Problemfunctions'])); % functions related to the turbine problem
    
    for ii = 1 : length(ind)
        costs(ii) = CF(ii).CF;
        caseNout{ii} = simOut{1,ii}.runCase;
    end
    
    
end