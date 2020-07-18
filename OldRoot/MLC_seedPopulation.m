%% MLC_seedPopulation 
%
% If a mlc.go function has finished all requesed generation but hasn't
% converged, restart a new mlc object, put a breakpoint in the mlc.go
% function before the while statements, then run this code and continue.
% This will replace part of the population with the best part of the
% population from the previously mlc object
assert(mlc.population.gen==1, ...
    'This script is only inteded to run in the first generation');
mlc0 = mlc;

%% Parameters
seedPct = 0.5; % Percentage of the population to replace with seed

%% Load the seed mlc object
fName = 'G:\Team Drives\ABLE_ATLAS_OffShore\save_GP\20190426-0056_2\20190429_013102mlc_ae.mat';
mlc2 = load(fName);
mlc2 = mlc2.mlc;

%% Insert the seeds
nSeedIdvs = round(mlc0.parameters.size * seedPct);
for idvN = 1:nSeedIdvs
    
    % Get the index of the individual in the table
    idvIdx = mlc0.population(1).individuals(idvN);
    
    % Get the index of the seed individual.
    %   Assume the population is sorted with the most fit first.
    seedIdx = mlc2.population(end).individuals(idvN);
    
    % Insert the seed
    mlc0.table.individuals(idvIdx) = ...
        mlc2.table.individuals(seedIdx);
    
    mlc0.table.hashlist(idvIdx) = ...
        mlc2.table.hashlist(seedIdx);
    
    mlc0.table.costlist(idvIdx) = ...
        mlc2.table.costlist(seedIdx);
    
end

mlc0.table.caseDifficulty = mlc2.table.caseDifficulty;

mlc = mlc0;