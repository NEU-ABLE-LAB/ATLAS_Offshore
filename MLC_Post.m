restoredefaultpath;
clear all; close all; clc;
dbstop if error

%% Initialization
addpath(pwd)
addpath(genpath([pwd,'/OpenMLC-Matlab-2'])); % OpenMLC classes and functions
addpath(genpath([pwd,'/MLC_Problemfunctions'])); % functions related to the turbine problem 
addpath(genpath([pwd,'/ParforProgMon'])); % Parfor progress monitor 

%% LOad MLC object

load('20200818_015729mlc_be.mat')

[~,nGenerations] = size(mlc.population);
nGenerations = nGenerations - 1;

nGensAnalyse = 20;
nTopInds = 10;




%% what load cases were run?
CaseNames = cell(1,nGenerations);
CaseNumbers = zeros(1,nGenerations);

for jj = 1 : nGenerations
    CaseNames{jj} = mlc.population(jj).caseN{1, 1};
    CaseNumbers(jj) = find(strcmp(mlc.parameters.problem_variables.runCases,CaseNames{jj}),1); 
end

%% what was the average cost of the top "TopIndividuals" on each load case

TopIndividuals = 10; 

TopScores = zeros(1,nGenerations);

for jj = 1 : nGenerations
    TopScores(jj) = mean(mlc.population(jj).costs(1:TopIndividuals));
end

%% equation of analysed individuals in each gen.
TopEquations = cell(nTopInds,6,nGenerations);
TopUsesState = zeros(nTopInds,6,nGenerations);

for ii = 1 : nTopInds
    for jj = 1 : nGenerations
        top_ind_number = mlc.population(jj).individuals(ii);
        top_ind_formal = mlc.table.individuals(top_ind_number).formal;
        for kk = 1:3+mlc.parameters.problem_variables.nStates
            equation = top_ind_formal{kk};
            for ll = 1 : mlc.parameters.problem_variables.nSensors
                out_numb = mlc.parameters.problem_variables.sensorIdxs(ll);
                outname = fields(mlc.parameters.problem_variables.outListIdx);
                out_name = ['! ' outname{out_numb} ' !'];
                to_replace1 = ['S' num2str(ll) ' '];
                to_replace2 = ['S' num2str(ll) ')'];
                equation = strrep(equation, to_replace1 ,out_name);
                equation = strrep(equation, to_replace2 ,out_name);
            end
            
            TopEquations{ii,kk,jj} = equation;
            TopUsesState(ii,kk,jj) = contains(equation, 'S32') + contains(equation, 'S33') + contains(equation, 'S34');
            
        end
    end
end

see = TopEquations{:,:,10};









