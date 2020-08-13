function Parameters = fConfigProblemParams()

%% Sensor Information
% outList is the list of all outputs in the outdata signal
Parameters.outListIdx = fGetOutList();




%   List of sensors in outdata that the GP will be able to use 
%   Comment out unused sensors
Parameters.sensorNames = { ...
    ... VARIABLES USED IN DEFAULT PID CONTROLLER
    'RotSpeed'  % Rotor azimuth angular speed	About the xa- and xs-axes	(rpm)
    'Azimuth'   % Rotor azimuth (deg). Replacing `GenSpeed` in the origional MLC. 
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

%number of sensors availble
Parameters.nSensors = length(Parameters.sensorNames);

% Convert index in sensorNames to index in outList, gives signal number of
% each of the sensors in sensorNames
Parameters.sensorIdxs = cellfun(@(x)(Parameters.outListIdx.(x)), Parameters.sensorNames);

%% Baseline Signal Information 
% Baseline signals and normalizations
disp('Loading baseline data')
baselineResults = load('BaselineSimout.mat');
disp('Baseline data loaded')

Parameters.BaselineSimout = baselineResults.simOut{1}.Channels(:, ...
    cellfun(@(x)(Parameters.outListIdx.(x)),fieldnames(Parameters.outListIdx)));
Parameters.BaselineMean = mean(Parameters.BaselineSimout);
Parameters.BaselineDetrendRMS = rms(Parameters.BaselineSimout - Parameters.BaselineMean);

% Baseline Stats
Parameters.Challenge = 'Offshore'                 ; % 'Offshore' or 'Onshore', important for cost function

case_file = 'Cases.csv';
CasesBase = fReadCases(case_file); % DLC Cases
Parameters.runCases = CasesBase.Names;

pMetricsBC = fMetricVars(CasesBase, Parameters.Challenge); % Parameters for the metrics computation

% Compute folder stats and spectra - or load them from a file
PreProFile=  ['PrePro_Offshore.mat'];
Parameters.statsBase = load(PreProFile);

end 
