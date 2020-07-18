%% fCostFunctionSimOut Compute the aggregate cost function across and array of simOut
function [CF, CF_Comp, CF_Vars, CF_Freq, pMetrics, Metrics, RunsStats] = ...
    fCostFunctionSimOut(simOut, Challenge, metricsBase)

%% Load case and metrics init

% Parameters for the metrics computation
if isa(simOut,'Simulink.SimulationOutput')
    
    Cases = fRegExpCases({simOut.runCase});
    
elseif isa(simOut,'cell')
    
    Cases = fRegExpCases( cellfun(@(x)(x.runCase), ...
        simOut, 'UniformOutput',false) );
    
end
    
[ pMetrics   ] = fMetricVars(Cases, Challenge)              ; 

%% Loop on results folder, compute cost function1
    
RunsStats = fComputeOutStats(simOut, pMetrics, Cases);

% --- Safety checks
id =find(ismember(RunsStats.ChanName, 'Wave1Elev'));
if isequal(lower(Challenge),'onshore') && ~isempty(id)
    error('You are trying to evaluate results from the "Offshore" challenge, but you provided the option "Onshore" to the cost function method. Most likely you are running in the wrong challenge folder.')
end
if isequal(lower(Challenge),'offshore') && isempty(id)
    error('You are trying to evaluate results from the "Onshore" challenge, but you provided the option "Offshore" to the cost function method. Most likely you are running in the wrong challenge folder.')
end

% --- Evaluate metrics and cost function
[ Metrics    ] = fEvaluateMetrics(RunsStats, pMetrics);

[CF, CF_Comp, CF_Vars, CF_Freq] = ...
    fCostFunction(Metrics.Values, metricsBase.Values, pMetrics);
CF_Freq = {CF_Freq};

% --- Safety check
if length(RunsStats.OutFiles)~=length(Cases.Names)
    warning('Only %d/%d files found in %s.', ...
        length(RunsStats.OutFiles), length(Cases.Names), folder); 
end
    

end