%% FASTPreSim Simulink presimulation file
%
% INPUTS
%   - in: Simulink model created by Simulink.SimulationInput()
%   - runCase: String describing the DLC scenario
%   - hSetControllerParameter: function handle to set controller parameters
%   - RootOutputFolder: Location to create run output folder
%   - FASTInputFolder: Location of FAST input files
%   - statsBase: Stats for all the base cases
%
% ref: fRunFAST.m
function in = FASTPreSim(in, runCase, hSetControllerParameter, ...
    RootOutputFolder, FASTInputFolder, Challenge, statsBase)

%% Prepend simulation name with timestamp
tStamp = [datestr(now,'YYYYmmDD-HHMMSS') '_' dec2hex(randi(2^16),4)]; % Add a random 4 char in case two parallel processes start at the same time
runName = [tStamp '_' runCase];
OutputFolder = [RootOutputFolder runName '/'];
mkdir(OutputFolder);

%% Copy FAST case input files
% This way the output file automatically has the time-stamped name
copyfile([FASTInputFolder runCase '.fst'], [FASTInputFolder runName '.fst'])
copyfile([FASTInputFolder runCase '_ED.dat'], [FASTInputFolder runName '_ED.dat'])
copyfile([FASTInputFolder runCase '_HD.dat'], [FASTInputFolder runName '_HD.dat'])
copyfile([FASTInputFolder runCase '_IW.dat'], [FASTInputFolder runName '_IW.dat'])
copyfile([FASTInputFolder runCase '_SD.dat'], [FASTInputFolder runName '_SD.dat'])

%% constants and specific to a given simulation.
fstFName  = [FASTInputFolder runName '.fst'];
    fprintf('\n');
    fprintf('-----------------------------------------------------------------------------\n');
    fprintf('>>> Simulating: %s \n',fstFName);
    fprintf('-----------------------------------------------------------------------------\n');
Parameter = fSetSimulinkParameters(fstFName, hSetControllerParameter); 

%% Set parameters to model
    
if isa(in, 'Simulink.SimulationInput')
    
    % Input is a Simulink simulation input object
    in = in.setVariable('runCase', runCase);
    in = in.setVariable('runName', runName);
    in = in.setVariable('Challenge', Challenge);
    in = in.setVariable('RootOutputFolder', RootOutputFolder);
    in = in.setVariable('OutputFolder', OutputFolder);
    in = in.setVariable('FASTInputFolder', FASTInputFolder);
    in = in.setVariable('statsBase', statsBase);
    in = in.setVariable('Parameter', Parameter);
    
elseif isa(in, 'Simulink.ModelWorkspace')
    
    % Input is a model workspace handle
    in.assignin('runCase', runCase);
    in.assignin('runName', runName);
    in.assignin('Challenge', Challenge);
    in.assignin('RootOutputFolder', RootOutputFolder);
    in.assignin('OutputFolder', OutputFolder);
    in.assignin('FASTInputFolder', FASTInputFolder);
    in.assignin('statsBase', statsBase);
    in.assignin('Parameter', Parameter);
    
else
    error('Unknown input type');
    
end


end