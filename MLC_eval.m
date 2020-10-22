%% MLC_eval Evaluates the fitness of an individual for a single case
%
%   INPUTS
%       ind - Current mlc.individuals
%       MLC_params - mlc.parameters
%       caseN - load case to run
%
function [costs, caseNout] = MLC_eval(ind, MLC_params,MLC_Runcase)
    

    costs = zeros(1, length(ind));
    caseNout = cell(1, length(ind));
    Sims = [];
    for ii = 1 : length(ind)
        if ind(ii).cost_history(MLC_Runcase) ~= -1
            costs(ii) = ind(ii).cost_history(MLC_Runcase);
            caseNout{ii} = MLC_Runcase;    
        else    
            [~,AllFcnText{ii}] = MLC_MLC2Fast(ind(ii).formal, MLC_params);
            Sims = [Sims ii];
        end
    end
    
    fcnText = AllFcnText(~cellfun('isempty',AllFcnText));    
    
    %Run sims
    cd(MLC_params.problem_variables.FastPath)
    Main_Par_MLC
    cd(MLC_params.problem_variables.MLCPath)    
    restoredefaultpath;
    addpath(pwd)
    addpath(genpath([pwd,'/OpenMLC-Matlab-2'])); % OpenMLC classes and functions
    addpath(genpath([pwd,'/MLC_Problemfunctions'])); % functions related to the turbine problem
    
    % Cleanup
    for ii = 1 : length(Sims)
        nInd = Sims(ii);
        costs(nInd) = CF(ii).CF;
        caseNout{nInd} = simOut{1,ii}.runCase;
    end
    
    for ii = 1 : length(ind)
       ind(ii).cost_history(MLC_Runcase) = costs(ii)  ;
    end    
    
    
    
    
end