restoredefaultpath;
clear all; close all; clc;
dbstop if error

%% Initialization
addpath(pwd)
addpath(genpath([pwd,'/OpenMLC-Matlab-2'])); % OpenMLC classes and functions
addpath(genpath([pwd,'/MLC_Problemfunctions'])); % functions related to the turbine problem
addpath(genpath([pwd,'/ParforProgMon'])); % Parfor progress monitor

%% Load MLC object

load('20201203_062004mlc_ae.mat')

[~,nGenerations] = size(mlc.population);
[~,nInds] = size(mlc.population(1).individuals);


%% Draw Plots
DrawPlots = false;

if DrawPlots
    %% what load cases were run?
    CaseNames = cell(1,nGenerations);
    CaseNumbers = zeros(1,nGenerations);
    
    for Gen = 1 : nGenerations
        CaseNames{Gen} = mlc.population(Gen).caseN{1, 1};
        
        %Because of old bug (Should be fixed now ) in the MLC Eval
        if isnumeric(CaseNames{Gen})
            CaseNames{Gen} = mlc.parameters.problem_variables.runCases(CaseNames{Gen});
        end
        
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
            for CtrlOutput = 1:3+mlc.parameters.problem_variables.nStates
                Equation = top_ind_formal{CtrlOutput};
                for Sensor = 1 : mlc.parameters.problem_variables.nSensors
                    out_numb = mlc.parameters.problem_variables.sensorIdxs(Sensor);
                    outname = fields(mlc.parameters.problem_variables.outListIdx);
                    out_name = ['! ' outname{out_numb} ' !'];
                    to_replace1 = ['S' num2str(Sensor - 1) ' '];
                    to_replace2 = ['S' num2str(Sensor - 1) ')'];
                    to_replace3 = ['S' num2str(Sensor - 1) ','];
                    Equation = strrep(Equation, to_replace1 ,[out_name ' ']);
                    Equation = strrep(Equation, to_replace2 ,[out_name ')']);
                    Equation = strrep(Equation, to_replace3 ,[out_name ',']);
                end
                
                TopEquations{Ind,CtrlOutput,Gen} = Equation;
                TopUsesState(Ind,CtrlOutput,Gen) = contains(Equation, 'S32') + contains(Equation, 'S33') + contains(Equation, 'S34');
            end
            % A species is the number of unique states each of the three outputs has
            Specie  = '';
            for CtrlOutput = 1 : 3
                Specie = [Specie num2str(TopUsesState(Ind,CtrlOutput,Gen)) '-'];
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
    ylim([min(Percentiles(1,:))-.02 max(Percentiles(6,:))+.02])
    xlim([1 nGenerations])
    ylabel('Cost')
    xlabel('Generation')
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
end



%% Individuals to Retest on all Simulations

nReEval = 10; %re evaluare the top ## individuals in each generation

nReEvalSets = 150; % break re evaluatibn into ## subsets, saving in between each subset, 
%use to save information in event re evlauation process craches

FastPath = 'D:\Documents\GitHub\ATLAS_FAST-par';
MLCPath = 'D:\Documents\GitHub\ATLAS_Offshore';

ReEvalFile = ['22-Jan-2021_MLCReEvaluation'];
ReEvalComplete = true;

if ReEvalComplete ~= true
    if   ~exist(ReEvalFile,'file')
        %Prealocate
        RE_IndNumberArray = zeros(nReEval, nGenerations);
        
        %Create array of top inds, NReEval x NGenerations
        TopInds = zeros(nReEval,1);
        for Gen = 1 : nGenerations
            TopInds = mlc.population(Gen).individuals(1:nReEval);
            RE_IndNumberArray(:,Gen) = TopInds';
        end
        
        RE_IndNumbs = unique(RE_IndNumberArray);
        RE_Tracker = zeros(length(RE_IndNumbs),1);
        RE_CtrlEquation = cell(length(RE_IndNumbs),1);
        RE_SimOut = RE_CtrlEquation;
        RE_CF = RE_CtrlEquation;
        RE_Ind = RE_CtrlEquation;
        
        for ReEvalInd = 1 : length(RE_IndNumbs)
            IndNumber = RE_IndNumbs(ReEvalInd);
            ind = mlc.table.individuals(IndNumber);
            RE_Ind{ReEvalInd} = ind;
            [~,RE_CtrlEquation{ReEvalInd}] = MLC_MLC2Fast(ind.formal, mlc.parameters);
        end
        
        FileName = strcat(date(),'_MLCReEvaluation');
        save(FileName,'RE_CF', 'RE_CtrlEquation', 'RE_Ind', 'RE_IndNumberArray', 'RE_IndNumbs', 'RE_SimOut', 'RE_Tracker')
    else
        load(ReEvalFile);
        FileName = ReEvalFile;
    end
    
    for Set =  1: nReEvalSets
        %get individuas in this set:
        SetSize = ceil(length(RE_IndNumbs)/nReEvalSets);
        SetSizeMax = min(SetSize,length(RE_IndNumbs));%To prevent it from indexing into empty individuals
        
        SetNumbers = (Set - 1)*SetSize + [1:SetSizeMax];
        
        %Check to see if individuals in this set have been re-evaluated
        IsNotReEvaluated = RE_Tracker(SetNumbers) == 0;
        SetNumbers = SetNumbers(IsNotReEvaluated);
        SetSize = length(SetNumbers);
        
        
        % Get controler text for this set
        SetfcnText = RE_CtrlEquation(SetNumbers);
        
        
        if ~isempty(SetfcnText)
            %re evaluate the controlers on all load cases
            [CF, SimOut, Costs] = MLC_PostEval(SetfcnText, mlc.parameters, FastPath, MLCPath);
            
            %Post Processing
            RE_Tracker(SetNumbers) = 1;
            for ind = 1:SetSize
                Setind = SetNumbers(ind);
                RE_CF{Setind} = CF(ind);
                RE_SimOut{Setind} = SimOut(:,ind);
                RE_Ind{Setind}.cost = CF(ind).CF;
                for LoadCase = 1:12
                    RE_Ind{Setind}.cost_history(LoadCase) = Costs{LoadCase,ind};
                end
            end
            
            save(FileName,'RE_CF', 'RE_CtrlEquation', 'RE_Ind', 'RE_IndNumberArray', 'RE_IndNumbs', 'RE_SimOut', 'RE_Tracker','-v7.3')
        end
        
    end
end

%% ReEevaluation analysis

load(ReEvalFile);

for ind = 1 : length(RE_CF)
    Costs(ind) = RE_CF{ind}.CF;
end

Min_Cost = min(Costs);
Min_IndNum = RE_IndNumbs(Costs == Min_Cost);
MinIndLoc = find(RE_IndNumberArray == Min_IndNum) / nReEval;
Min_IndGen = ceil(MinIndLoc);
Min_IndGenRank = round((MinIndLoc - floor(MinIndLoc)) * nReEval,0);
Min_CtrlLaw = RE_CtrlEquation{Costs == Min_Cost};

%Print Best Inividual Properties
fprintf('BEST INDIVIDUAL:\nIndividual number %i\nGeneration %i, Gen. Rank %i\nCOST = %f\n\n',Min_IndNum,Min_IndGen,Min_IndGenRank,Min_Cost)

%% Plot histogram with overall cost trend of best individual in each gen.

StartGen = 25; %Generation To start plot at 
EndGen = 100; %Generation to end plot at

figure
hold on
for Gen = 1 : EndGen - StartGen + 1
    GenNum = StartGen + Gen - 1;
    AllCosts(:,Gen) = mlc.population(Gen).costs; 
    for TopInd = 1: nReEval   
        TMinTotal(TopInd) = min(Costs(RE_IndNumbs == RE_IndNumberArray(TopInd,GenNum)));
    end
    MinTotal(Gen) = min(TMinTotal);
    Gens(Gen) = GenNum;
end    
boxplot(AllCosts,Gens,'PlotStyle','compact','OutlierSize',1)
plot(MinTotal,'LineWidth',4)
ylim([.5,1.5])
xlabel('Generation')
ylabel('Cost')
hold off






