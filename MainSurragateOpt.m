%% MainSurrogateOpt
restoredefaultpath;
clear all;
close all;
clc;
dbstop if error

%% Initialization
% ref: Main.m
addpath(pwd)
addpath(genpath([pwd,'/_Functions']));  % Matlab functions for cost function and running cases - READ ONLY
addpath(genpath([pwd,'/_Controller'])); % Simulink model, where user scripts and models are placed
addpath(genpath([pwd,'/OpenMLC-Matlab-2'])); % OpenMLC classes and functions

%% Script Parameters
% ref: Main.m

Challenge              = 'Offshore'                 ; % 'Offshore' or 'Onshore', important for cost function
FASTInputFolder        = [pwd '/_Inputs/LoadCases/'] ; % directory of the FAST input files are (e.g. .fst files)
case_file              = [pwd '/_Inputs/_inputs/Cases.csv']; % File defining the cases that are run
BaselineFolder         = [pwd '/_BaselineResults/'] ; % Folder where "reference simulations are located"
RootOutputFolder       = [pwd '/_Outputs/']         ; % Folder where the current simulation outputs will be placed
ctrlFolder             = [pwd '/_Controller/']      ; % Location of Simulink files
% All paths have to be absolute because of parallelization


%% Script Preprocessing

% Load case and metrics init
CasesBase = fReadCases(case_file); % DLC Cases
pMetricsBC = fMetricVars(CasesBase, Challenge); % Parameters for the metrics computation

% Compute folder stats and spectra - or load them from a file
PreProFile= [BaselineFolder 'PrePro_' Challenge '.mat'];
if ~exist(PreProFile,'file')
    statsBase = fComputeOutStats(BaselineFolder, pMetricsBC, ...
        CasesBase, PreProFile);
else
    statsBase = load(PreProFile);
end

% Evaluate metrics and cost function
metricsBase = fEvaluateMetrics(statsBase, pMetricsBC);

%% Model Parameters
% ref: Main.m

% path to the Simulink model (should be in the folder `_Controller`, saved as a `.slx` file)
sysMdl = 'MLC_IPC_sys';
ctrlMdl = 'MLC_IPC_ctrl'; % Reference model for controller

% Input file specification name
runCases = CasesBase.Names;

% handle to the function which sets the Controller parameter (should be in the folder '_Controller')
hSetControllerParameter = @fSetControllerParametersOffshore; 

%% Optimization Parameters


% SENSORS
%   Comment out unused sensors
sensorNames = { ...
    ... VARIABLES USED IN DEFAULT PID CONTROLLER
    'RotSpeed'  % Rotor azimuth angular speed	About the xa- and xs-axes	(rpm)
    'GenSpeed'  % Angular speed of the high-speed shaft and generator	Same sign as LSSGagVxa / LSSGagVxs / LSSGagV	(rpm)
    'BldPitch1' % Blade 1 pitch angle (position)	Positive towards feather about the minus zc1- and minus zb1-axes	(deg)
    'BldPitch2' % Blade 2 pitch angle (position)	Positive towards feather about the minus zc2- and minus zb2-axes	(deg)
    'BldPitch3' % Blade 3 pitch angle (position)	Positive towards feather about the minus zc3- and minus zb3-axes	(deg)
    ... VARIABLES USED IN COST FUNCTION
    'RootMyc1'  % Blade 1 out-of-plane moment (i.e., the moment caused by out-of-plane forces) at the blade root
    'RootMzc1'  % Blade 1 pitching moment at the blade root
    'RootMyc2'  % Blade 2 out-of-plane moment (i.e., the moment caused by out-of-plane forces) at the blade root
    'RootMzc2'  % Blade 2 pitching moment at the blade root
    'RootMyc3'  % Blade 3 out-of-plane moment (i.e., the moment caused by out-of-plane forces) at the blade root
    'RootMzc3'  % Blade 3 pitching moment at the blade root
    'RotTorq'   % Low-speed shaft torque (this is constant along the shaft and is equivalent to the rotor torque)
    'TwrBsMyt'  % Tower base pitching (or fore-aft) moment (i.e., the moment caused by fore-aft forces)
    'GenPwr'    % Electrical generator power
    'NcIMUTAxs' % Nacelle inertial measurement unit translational acceleration (absolute)	Directed along the xs-axis
    'NcIMUTAys' % Nacelle inertial measurement unit translational acceleration (absolute)	Directed along the ys-axis
    'NcIMUTAzs' % Nacelle inertial measurement unit translational acceleration (absolute)	Directed along the zs-axis
    'PtfmPitch' % Platform pitch tilt angular (rotational) displacement. In ADAMS, it is output as an Euler angle computed as the 2nd rotation in the yaw-pitch-roll rotation sequence. It is not output as an Euler angle in FAST, which assumes small rotational platform displacements, so that the rotation sequence does not matter.	About the yi-axis
    'PtfmRoll'
    'PtfmYaw'
    'PtfmSurge'
    'PtfmSway'
    'PtfmHeave'
    ... WIND SENSORS
    'Wind1VelX' % X-direction wind velocity at point WindList(1)
    'Wind1VelY' % Y-direction wind velocity at point WindList(1)
    'Wind1VelZ' % Z-direction wind velocity at point WindList(1)
    'NacYaw'    % Nacelle yaw angle (position)
    ... WAVE AND MOORING SENSORS
    'Wave1Elev' % Wave elevation at the platform reference point (0,  0)
    'T_1'
    'T_2'
    'T_3'
    };

nSensors = length(sensorNames);

outListIdx = struct('Time',1,'Wind1VelX',2,'Wind1VelY',3,...
    'Wind1VelZ',4,'BldPitch1',5,'BldPitch2',6,'BldPitch3',7,'Azimuth',8,...
    'RotSpeed',9,'GenSpeed',10,'NacYaw',11,'OoPDefl1',12,'IPDefl1',13,...
    'TwstDefl1',14,'OoPDefl2',15,'IPDefl2',16,'TwstDefl2',17,...
    'OoPDefl3',18,'IPDefl3',19,'TwstDefl3',20,'TwrClrnc1',21,...
    'TwrClrnc2',22,'TwrClrnc3',23,'NcIMUTAxs',24,'NcIMUTAys',25,...
    'NcIMUTAzs',26,'TTDspFA',27,'TTDspSS',28,'TTDspTwst',29,...
    'PtfmSurge',30,'PtfmSway',31,'PtfmHeave',32,'PtfmRoll',33,...
    'PtfmPitch',34,'PtfmYaw',35,'PtfmRVxt',36,'PtfmRVyt',37,...
    'PtfmRVzt',38,'PtfmTAxt',39,'PtfmTAyt',40,'PtfmTAzt',41,...
    'RootFxc1',42,'RootFyc1',43,'RootFzc1',44,'RootMxc1',45,...
    'RootMyc1',46,'RootMzc1',47,'RootFxc2',48,'RootFyc2',49,...
    'RootFzc2',50,'RootMxc2',51,'RootMyc2',52,'RootMzc2',53,...
    'RootFxc3',54,'RootFyc3',55,'RootFzc3',56,'RootMxc3',57,...
    'RootMyc3',58,'RootMzc3',59,'Spn1MLxb1',60,'Spn1MLyb1',61,...
    'Spn1MLzb1',62,'Spn1MLxb2',63,'Spn1MLyb2',64,'Spn1MLzb2',65,...
    'Spn1MLxb3',66,'Spn1MLyb3',67,'Spn1MLzb3',68,'LSSTipMya',69,...
    'LSSTipMza',70,'RotThrust',71,'LSSGagFya',72,'LSSGagFza',73,...
    'RotTorq',74,'LSSGagMya',75,'LSSGagMza',76,'RotPwr',77,...
    'HSShftTq',78,'YawBrFxp',79,'YawBrFyp',80,'YawBrFzp',81,...
    'YawBrMxp',82,'YawBrMyp',83,'YawBrMzp',84,'YawBrTAxp',85,...
    'YawBrTAyp',86,'TwrBsFxt',87,'TwrBsFyt',88,'TwrBsFzt',89,...
    'TwrBsMxt',90,'TwrBsMyt',91,'TwrBsMzt',92,'RootMyb1',93,...
    'NcIMUTVxs',94,'RtTSR',95,'RtAeroCp',96,'RtAeroCt',97,...
    'B1N3Clrnc',98,'GenPwr',99,'GenTq',100,'BlPitchC1',101,...
    'BlPitchC2',102,'BlPitchC3',103,'Wave1Elev',104,'T_1',105,...
    'T_a_1',106,'T_2',107,'T_a_2',108,'T_3',109,'T_a_3',110);

% Convert index in sensorNames to index in outList
sensorIdxs = cellfun(@(x)(outListIdx.(x)), sensorNames);

% Load baseline data
disp('Loading baseline data')
baselineResults = load([BaselineFolder 'baselineResults.mat'],'simOut');
disp('Baseline data loaded')

% Baseline signals and normalizations
sensors = baselineResults.simOut(1).Channels(:, ...
    cellfun(@(x)(outListIdx.(x)),fieldnames(outListIdx)));
sensorsMean = mean(sensors);
sensorsDetrendRMS = rms(sensors - sensorsMean);

% (struct)[] A structure of data/variables to pass to `evaluation_function`
pMLC.problem_variables=struct(... 
    'outListIdx', {outListIdx}, ...
    'sensorNames', {sensorNames}, ...
    'sensorIdxs', {sensorIdxs}, ...
    'nSensors', {nSensors}, ...
    'runCases', {runCases}, ...
    'sysMdl', {sysMdl}, ...
    'ctrlMdl', {ctrlMdl}, ...
    'ctrlFolder', {ctrlFolder}, ...
    'RootOutputFolder', {RootOutputFolder}, ...
    'FASTInputFolder', {FASTInputFolder}, ...
    'Challenge', {Challenge}, ...
    'statsBase', {statsBase}, ...
    'sensors', {sensors}, ...
    'sensorsMean', {sensorsMean}, ...
    'sensorsDetrendRMS', {sensorsDetrendRMS});

hSetControllerParameter = @(pSim)hSetControllerParameter(pSim,pMLC);

%% Surragate Opt Options

N = 20; % any even number
mf = 200; % max fun evals
fun = @multirosenbrock;
lb = -3*ones(1,N);
ub = -lb;
rng default
x0 = -3*rand(1,N);

options = optimoptions('surrogateopt',...
    'MaxFunctionEvaluations',mf);
% Evaluation function

% Constraints

% Gains