function [CF, CF_Comp, CF_Vars, CompNames, VarNames, pMetrics, Metrics, FilesStats] = fCostFunctionFolder(folder, case_file, scale_file);
% Computes cost function given a calculation folder
%
% see fCostFunction.m for desciption of inputs/outputs
[ Cases      ] = fReadCases(case_file)                       ; % DLC Cases
[ pMetrics   ] = fMetricVars(Cases, scale_file)              ; % Parameters for the metrics computation
fprintf('>>> Computing stats for folder %s \n',folder);
[ FilesStats ] = fComputeOutStats(folder, pMetrics);
[ Metrics    ] = fEvaluateMetrics(FilesStats, pMetrics);
[CF, CF_Comp, CF_Vars, CompNames, VarNames] = fCostFunction(Metrics.Values, pMetrics);

if length(FilesStats.OutFiles)~=length(Cases.Names);
    warning('Only %d/%d files found in %s.',length(FilesStats.OutFiles), length(Cases.Names), folder); 
end;
