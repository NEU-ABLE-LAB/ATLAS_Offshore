function Parameter = fSetSimulinkParameters(FASTfile, hSetControllerParameter )
% Sets the structure "Parameter" that contains the infomation used by the simulink model
%
% Amongst those parameters are:
%  - turbine specific parameters (set within this function)
%  - controller specific parameters (set with the function hSetControllerParameter) 
%  
% 
% INPUTS:
%   - FASTfile               : fast input file (.fst), used to set the initial conditions and simulation length
%   - hSetControllerParameter: handle to a matlab function
%       The function should take a structure as inputs and adds additional fields to it.
%       The fields added to the structure can be used in the Simulink model. 
%       The structure name is `Parameter`.
%       For an example of such function see the file '_Controller\fSetControllerParameter.m'
%       NOTE: functions handles are referenced with "@", e.g.  @fSetControllerParameter
%
% 
% --- Opening FASTfile
p          = fFAST2MATLAB(FASTfile)                ;
TMax       = str2double(fGetVal(p,'TMax'  ))       ;
dt         = str2double(fGetVal(p,'DT'    ))       ;
EDFile     = strrep(    fGetVal(p,'EDFile'),'"','');
simdir     = fileparts(FASTfile);
if ~isempty(simdir); simdir=[simdir '\']; end
ed         = fFAST2MATLAB([simdir EDFile])     ;
pitch_init = str2double(fGetVal(ed,'BlPitch(1)'))  ;

% --------------------------------------------------------------------------------}
%% --- DEFAULT Turbine Parameters
% --------------------------------------------------------------------------------{
Parameter = struct();
% --- Turbine  
Parameter.Turbine.Omega_rated = rpm2radPs(12.1);       % [rad/s]
Parameter.Turbine.P_el_rated  = 5e6;                      % [W]
Parameter.Turbine.i  = 1/97;
% --- Generator
Parameter.Generator.eta_el      	= 0.944;                % [-]
Parameter.Generator.M_g_dot_max     = 15e3;                 % [-]
% --- PitchActuator            
Parameter.PitchActuator.Mode            = 2;                % 0: none; 1: Delay; 2: PT2 (omega, xi, x1_con)
Parameter.PitchActuator.omega           = 2*pi;             % [rad/s]
Parameter.PitchActuator.xi              = 0.7;              % [-]
Parameter.PitchActuator.theta_dot_max 	= deg2rad(8);       % [rad/s]
Parameter.PitchActuator.theta_max     	= deg2rad(90);      % [rad]
Parameter.PitchActuator.theta_min     	= deg2rad(0);       % [rad]
Parameter.PitchActuator.Delay           = 0.2;              % [s]


% --------------------------------------------------------------------------------}
%% --- SIMULATION Dependent parameters 
% --------------------------------------------------------------------------------{
% -- Initial Conditions at 13.5934 m/s - NEED TO BE REPLACED
fprintf('Simulation params: T=%.0f - pitch_0=%.1f\n',TMax,pitch_init); 
Parameter.IC.theta                      = deg2rad(pitch_init);  	% [rad]              
Parameter.IC.M_g                        = 43093.55;       	% [Nm] 
Parameter.IC.Omega                      = rpm2radPs(12.1); 	% [rad/s]
NDOF = 24;
Parameter.IC.q              = zeros(1,NDOF);
Parameter.IC.q(7)           = 0.252;            % [m]   1st tower fore-aft mode
Parameter.IC.q(14)          = 0.00482;          % [rad] drivetrain rotational-flexibility.
Parameter.IC.q([16,19,22])  = 3.41;             % [m]   1st blade flap mode
Parameter.IC.qdot           = zeros(1,NDOF);
Parameter.IC.qdot(13)       = Parameter.IC.Omega;

Parameter.Time.dt           = 1/80;
Parameter.Time.TMax         = TMax;
Parameter.FASTfile          = FASTfile;

% --------------------------------------------------------------------------------}
%% --- Torque Controller parameters 
% --------------------------------------------------------------------------------{
%% NREL 5MW Baseline Torque Controller
Parameter.VSC.k                         = radPs2rpm(radPs2rpm(0.0255764));  % [Nm/(rad/s)^2]
Parameter.VSC.theta_fine                = deg2rad(1);                       % [rad]      
Parameter.VSC.Mode                      = 2;                                % 1: ISC, constant power in Region 3; 2: ISC, constant torque in Region 3 
Parameter.VSC.P_a_rated                 = Parameter.Turbine.P_el_rated/Parameter.Generator.eta_el;                % [W]
% Parameter.VSC.M_g_rated                 = Parameter.VSC.P_a_rated/Parameter.Turbine.Omega_rated;  % [Nm] 
Omega_g_rated  = Parameter.Turbine.Omega_rated/Parameter.Turbine.i;  % [rad/s]
Parameter.VSC.M_g_rated                 = Parameter.VSC.P_a_rated/Omega_g_rated;  % [Nm] 
Parameter.VSC.M_g_max                   = Parameter.VSC.M_g_rated*1.1;      % [Nm] 
Parameter.VSC.M_g_min                   = 0;                                % [Nm] 

% region limits & region parameters from Jonkman 2009
Parameter.VSC.Omega_g_1To1_5            = rpm2radPs(670);                   % [rad/s]
Parameter.VSC.Omega_g_1_5To2            = rpm2radPs(871);                   % [rad/s]
Parameter.VSC.Omega_g_2_5To3            = rpm2radPs(1161.963);              % [rad/s]

% Region 1_5: M_g = a * Omega_g + b: 
% 1.Eq: 0                   = a * Omega_g_1To1_5 + b 
% 2.Eq: k*Omega_g_1_5To2^2  = a * Omega_g_1_5To2 + b
Parameter.VSC.a_1_5                     = Parameter.VSC.k*Parameter.VSC.Omega_g_1_5To2^2/(Parameter.VSC.Omega_g_1_5To2-Parameter.VSC.Omega_g_1To1_5);
Parameter.VSC.b_1_5                     = -Parameter.VSC.a_1_5*Parameter.VSC.Omega_g_1To1_5;

% Region 2_5: M_g = a * Omega_g + b: 
% 1.Eq: 0                   = a * Omega_slip        + b 
% 2.Eq: M_g(Omega_g_2_5To3) = a * Omega_g_2_5To3    + b
GeneratorSlipPercentage                 = 0.1;                              % [-]
Omega_slip                              = Parameter.VSC.Omega_g_2_5To3/(1+GeneratorSlipPercentage);
Parameter.VSC.a_2_5                     = (Parameter.VSC.P_a_rated/Parameter.VSC.Omega_g_2_5To3)/(Parameter.VSC.Omega_g_2_5To3-Omega_slip);
Parameter.VSC.b_2_5                     = -Parameter.VSC.a_2_5*Omega_slip;

% intersection k * Omega_g^2 = a * Omega_g + b:
Parameter.VSC.Omega_g_2To2_5            = (Parameter.VSC.a_2_5 - (Parameter.VSC.a_2_5^2+4*Parameter.VSC.k*Parameter.VSC.b_2_5)^.5) / (2*Parameter.VSC.k);

%% FilterGenSpeed.Omega_g                   
Parameter.Filter.FilterGenSpeed.Omega_g.Enable          = 1;                % [-]
Parameter.Filter.FilterGenSpeed.T63                     = 1/(0.25*2*pi);    % [s], Rise time of PT1 for generator speed filter

% --------------------------------------------------------------------------------}
%% --- Controller parameters set using user defined function 
% --------------------------------------------------------------------------------{
Parameter  = hSetControllerParameter(Parameter); 

end


function y = rpm2radPs(u)
    y = u * 2*pi/60;
end
function y = radPs2rpm(u)
    y = u * 60/(2*pi);
end

