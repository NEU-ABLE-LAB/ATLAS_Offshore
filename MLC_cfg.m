%% MLC_cfg sets the parameters for the MLC problem
%
% INPUTS:
%   runCases - The name of all the cases to run
function pMLC = MLC_cfg(runCases ,sysMdl, ctrlMdl, hSetControllerParameter, ...
    ctrlFolder, BaselineFolder, RootOutputFolder, FASTInputFolder, ...
    Challenge, statsBase, initialPop)

%% Custom Parmeters

% SENSORS
%   Comment out unused sensors
sensorNames = { ...
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

%% GP problem parameters            % (data type)[default] Description
pMLC.size=500;                %*(num)[1000]$N_i$ Population size
pMLC.sensors=...              %*(num)[1]$N_s$ Number of sensors
    nSensors;
pMLC.sensor_spec=0;           % ?(bool)[0] Is a sensor list provided
pMLC.controls=3;              %*(num)[1]$N_b$ Number of controls
pMLC.sensor_prob=0.33;        % (num)[0.33] Probability of adding a sensor (vs constant) when creating leaf
pMLC.leaf_prob=0.3;           % (num)[0.3] Probability of creating a leaf (vs adding operation) 
pMLC.range=10;                %*(num)[10] New constants in GP will be drawn from +/- this range
pMLC.precision=4;             % (num)[4] Maximum number of significant digits of new constants
pMLC.opsetrange=1:7;          % (array)[1:9] An array specifying the mathematical operations used by the GP, as specified in `opset.m`
                           %   - 1  addition       (+)
                           %   - 2  substraction   (-)
                           %   - 3  multiplication (*)
                           %   - 4  division       (%)
                           %   - 5  sinus         (sin)
                           %   - 6  cosinus       (cos)
                           %   - 7  logarithm     (log)
                           %   - 8  exp           (exp)
                           %   - 9  tanh          (tanh)
                           %   - 10 modulo        (mod)
                           %   - 11 power         (pow)
pMLC.individual_type='tree';  % (str)['tree'] The only acceptable type is 'tree'


%% GP algorithm parameters  % (data type)[default] Description
% (CHANGE IF YOU KNOW WHAT YOU DO)
pMLC.maxdepth=15;              % (num)[15] Maximum depth of program tree
pMLC.maxdepthfirst=5;          % (num)[5] 
pMLC.mindepth=2;               % (num)[2] Minimum depth of program tree
pMLC.mutmaxdepth=15;           % (num)[15] 
pMLC.mutmindepth=2;            % (num)[2]
pMLC.mutsubtreemindepth=2;     % (num)[2]
pMLC.generation_method=...     % (str)['mixed_ramped_gauss'] The method of generating tree
    'mixed_ramped_gauss';   %   'random_maxdepth' - 
                            %   'fixed_maxdepthfirst' 
                            %   'random_maxdepthfirst'
                            %   'full_maxdepthfirst'
                            %   'mixed_maxdepthfirst' 
                            %   'mixed_ramped_even' - 
                            %   'mixed_ramped_gauss' -
                            %   SEE: Duriez 2017 pg 25
pMLC.gaussigma=3;              % (num)[3] The variance?? for the 'mixed_ramped gauss' generation method
pMLC.ramp=2:8;                 % (array)[2:8]
pMLC.maxtries=10;              % (num)[10]
pMLC.mutation_types=1:4;       % (array)[1:4]


%% Optimization parameters     % (data type)[default] Description
pMLC.elitism=10;                  %*(num)[10]$N_e$ Number of best individuals to carry over to next generation
pMLC.probrep=0.1;                 %*(num)[0.1]$P_r$ Probability of replication
pMLC.probmut=0.5;                 %*(num)[0.4]$P_m$ Probability of mutation
pMLC.probcro=0.4;                 %*(num)[0.5]$P_c$ Probability of crossover
pMLC.selectionmethod='tournament';% (str)['tournament'] The only acceptable type is 'tournament'
pMLC.tournamentsize=7;            % (num)[7]$N_p$ The number of individuals that enter the tournament
pMLC.lookforduplicates=1;         % (bool)(1) Remove (strict) duplicates 
pMLC.simplify=0;                  % (bool)(0) Simplify LISP expressions
pMLC.cascade=[1 1];               % (array)[1 1] Sets `obj.subgen` properties. See `MLCop.m`


%% Evaluator parameters           % (data type)[default] Description
pMLC.evaluation_method=...        %*(str)['mfile_standalone'] Evaluation method, choose one:
...     'mfile_standalone';       %   `mfile_standalone` Compute serial
    'mfile_multi';                %   `mfile_multi` Compute in parallel
pMLC.evaluation_function=...      %*(expr)['toy_problem'] Cost function name. 
    'MLC_eval';                   %   `J=evalFun(ind,mlc_parameters,i,fig)`
pMLC.nCases=12;                   %*(num)[1] The number different design cases that a population could be subjected to
pMLC.ev_again_best=1;             %*(bool)[0] Should elite individuals be reevaluated
pMLC.ev_again_nb=48;              % ?(num)[5] Number off best individuals to reevaluate. Should probably be similar to `elitism`.
pMLC.ev_again_times=1;            % ?(num)[5] The number of times to reevaluate best individuals
pMLC.execute_before_evaluation='';% (expr)[''] A Matlab expression to be evaluated with `eval()` before evaluation.
pMLC.badvalue=1000;               %*(num)[1E36] The value to return when `evaluation_function` determines the controller is 'bad'
pMLC.badvalues_elim='all';        % (str)['first'] When should bad individuals be eliminated
                               %   'none' Never remove bad individuals
                               %   'first' Only remove bad individuals in the first generation
                               %   'all' Remove bad individuals during all generations
pMLC.preevaluation=1;             %*(bool)[0] Should individuals be pre-evaluated
pMLC.preev_function='MLC_preeval';% (expr)[''] A Matlab expression to be evaluated with `eval()` to pre-evalute an individual
                               %   Expression should return `1` if pre-evaluation identified a valid individual
if exist('initialPop','var') && ~isempty(initialPop)
	pMLC.initialPop = initialPop;
end
                               
%% Problem Specific Parameters

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

% Process the MLC parameters through the model parameters
pMLC.problem_variables.hSetControllerParameter = ...
    @(pSim)hSetControllerParameter(pSim, pMLC);

%% MLC behavior parameters     % (data type)[default] Description
pMLC.save=1;                      % (bool)[1] Should populations be saved to `mlc_be.mat` every time they're created and to `mlc_ae.mat` after evaluation
pMLC.savedir=...                  % (str)[fullfile(pwd,'save_GP')] The directory to save files to
    'G:\Team Drives\ABLE_ATLAS_OffShore\save_GP';   % ?(bool)[1] Should incomplete evaulations be saved
pMLC.saveincomplete=1;            %
pMLC.verbose=2;                   % (num)[2] Level of verbose output: `0`, `1`, `2`, ...
