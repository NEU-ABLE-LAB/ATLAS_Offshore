restoredefaultpath;
clear all; close all; clc;
dbstop if error

%% Initialization
addpath(pwd)
addpath(genpath([pwd,'/OpenMLC-Matlab-2'])); % OpenMLC classes and functions
addpath(genpath([pwd,'/MLC_Problemfunctions'])); % functions related to the turbine problem 
addpath(genpath([pwd,'/ParforProgMon'])); % Parfor progress monitor 

%% LOad MLC object

load('20200916_163655mlc_ae.mat')

[~,nGenerations] = size(mlc.population);

[~,nInds] = size(mlc.population(1).individuals);



%% what load cases were run?
CaseNames = cell(1,nGenerations);
CaseNumbers = zeros(1,nGenerations);

for Gen = 1 : nGenerations
    CaseNames{Gen} = mlc.population(Gen).caseN{1, 1};
    CaseNumbers(Gen) = find(strcmp(mlc.parameters.problem_variables.runCases,CaseNames{Gen}),1); 
end

%% what was the average cost of the top "TopIndividuals" on each load case

TopIndividuals = 10; 

TopScores = zeros(1,nGenerations);

for Gen = 1 : nGenerations
    TopScores(Gen) = mean(mlc.population(Gen).costs(1:TopIndividuals));
end

%% equation of analysed individuals in each gen.
TopEquations = cell(nInds,6,nGenerations);
TopUsesState = zeros(nInds,6,nGenerations);
ControlerSpecies = cell(nInds,nGenerations);
ControlerCosts = zeros(nInds,nGenerations);

for Gen = 1 : nGenerations
    for Ind = 1 : nInds
        top_ind_number = mlc.population(Gen).individuals(Ind);
        top_ind_formal = mlc.table.individuals(top_ind_number).formal;
        for kk = 1:3+mlc.parameters.problem_variables.nStates
            Equation = top_ind_formal{kk};
            for ll = 1 : mlc.parameters.problem_variables.nSensors
                out_numb = mlc.parameters.problem_variables.sensorIdxs(ll);
                outname = fields(mlc.parameters.problem_variables.outListIdx);
                out_name = ['! ' outname{out_numb} ' !'];
                to_replace1 = ['S' num2str(ll) ' '];
                to_replace2 = ['S' num2str(ll) ')'];
                to_replace3 = ['S' num2str(ll) ','];
                Equation = strrep(Equation, to_replace1 ,[out_name ' ']);
                Equation = strrep(Equation, to_replace2 ,[out_name ')']);
                Equation = strrep(Equation, to_replace3 ,[out_name ',']);
            end
            
            TopEquations{Ind,kk,Gen} = Equation;
            TopUsesState(Ind,kk,Gen) = contains(Equation, 'S32') + contains(Equation, 'S33') + contains(Equation, 'S34');
        end
        % A species is the number of unique states each of the three outputs has 
        Specie  = '';
        for kk = 1 : 3
            Specie = [Specie num2str(TopUsesState(Ind,kk,Gen)) '-'];  
        end
        Specie = Specie(1:end-1);
        ControlerSpecies{Ind,Gen} = Specie;
        ControlerCosts(Ind,Gen) = mlc.population(Gen).costs(Ind);
    end
end

%% Percentiles Graph
Percentiles = zeros(11,nGenerations);
PercentileRange = [0:.1:1];
Colors = ['g' 'k' 'k' 'k' 'k' 'r' 'k' 'k' 'k' 'k' 'b'];
for Gen = 1 : nGenerations
    for Percentile = 1 : 11
        if Percentile == 1
            Percentiles(Percentile,Gen) = ControlerCosts(1,Gen);
        else
            PercentileValue = floor(PercentileRange(Percentile)*nInds);
            Percentiles(Percentile,Gen) = ControlerCosts(PercentileValue,Gen);
        end
    end
end

figure
hold on
for Percentile = 1 : 10   %Dont plot 100 percentile, usualy 1000 and off the chart
    plot([1:nGenerations],Percentiles(Percentile,:),Colors(Percentile));
end    
ylim([min(Percentiles(1,:))-.02 1.25])   
xlim([1 nGenerations])  
hold off

%% Cases plot
figure
plot(CaseNumbers,'x')

%% Species Plot
Species = unique(ControlerSpecies);
for Gen = 1 : nGenerations
    for Index = 1 : size(Species)  
        nSpecies(Index, Gen) = sum(count(ControlerSpecies(:,Gen),Species(Index)));    
    end
end
figure

bar(nSpecies','stacked');
hold all

legend(Species)
    
%% retest champs on all 12 cases
load('ChampsAllCases.mat')

%Pre
champs = unique(mlc.population(1, 50).champions);
%Comp
fcnText = cell(1, length(champs));

for ii = 1 : length(champs)
    ind = mlc.table.individuals(champs(ii));
    [~,fcnText{ii}] = MLC_MLC2Fast(ind.formal, mlc.parameters);
end
 
if false
    cd(mlc.parameters.problem_variables.FastPath)
    
    Main_Par_MLCPost
    
    cd(mlc.parameters.problem_variables.MLCPath)
    restoredefaultpath;
    addpath(pwd)
    addpath(genpath([pwd,'/OpenMLC-Matlab-2'])); % OpenMLC classes and functions
    addpath(genpath([pwd,'/MLC_Problemfunctions'])); % functions related to the turbine problem
    
end

%% champ analysis

Generation = nGenerations;

IndList = mlc.population(Generation).individuals;
ChampsFinal = mlc.population(Generation).champions;
ChampText = cell(mlc.parameters.champions, mlc.parameters.nCases);
ChampPlace = zeros(mlc.parameters.champions, mlc.parameters.nCases);
Equation = cell(1,6);

for ii = 1 : mlc.parameters.nCases  
    for jj = 1 : mlc.parameters.champions  
        for kk = 1 : 6
            Equation{kk} = TopEquations{IndList == ChampsFinal(jj,ii), kk, Generation};
        end
        ChampText{jj,ii} = Equation;
        ChampPlace(jj,ii) = find(IndList == ChampsFinal(jj,ii));
    end
end













