function [Parameter] = fSetControllerParametersOffshore(Parameter)
% Sets the controller parameter.
% This function takes a structure and supplements it with additional fields for the controller parameters.
% 
% NOTE: THE FIELDS ALREADY PRESENT IN THE INPUT STRUCTURE SHOULD NOT BE CHANGED. IT IS AGAINST THE COMPETITION's RULES.
% 
% 
% INPUTS:
%    Parameter: a structure containing information about the turbine and the operating conditions of the simulation
%
% OUTPUTS:
%    Parameter: the input structure supplemented with additional fields.
%
%    The (read only) fields present in the input structure are: 
%        % --- Turbine
%        Parameter.Turbine.Omega_rated = 12.1*2*pi/60 % Turbine rated rotational speed, 12.1rpm [rad/s]
%        Parameter.Turbine.P_el_rated  = 5e6 ; % Rated electrical power [W]
%        Parameter.Turbine.i           = 1/97; % The gear ratio
%        % --- Generator
%        Parameter.Generator.eta_el       = 0.944;                % [-]
%        Parameter.Generator.M_g_dot_max  = 15e3;                 % [-]
%        % --- PitchActuator, e.g.
%        Parameter.PitchActuator.omega         = 2*pi;             % [rad/s]
%        Parameter.PitchActuator.theta_max     = deg2rad(90);      % [rad]
%        Parameter.PitchActuator.theta_min     = deg2rad(0);       % [rad]
%        Parameter.PitchActuator.Delay         = 0.2;              % [s]
%        % -- Variable speed torque controller
%        Parameter.VSC   % Structure containing the inputs for the variable speed controller. READ ONLY.
%        % -- Initial Conditions, e.g.
%        Parameter.IC.theta   % Pitch angle [rad]              
%        % -- Simulation Params
%        Parameter.Time.TMax  % Simulation length [s]
%        Parameter.Time.dt    % Simulation time step [s]


%% Controller parameters for the Collective Pitch Controller (CPC)
% NOTE: these parameters are only used by NREL5MW_Baseline.mdl.
 % Delete them if another model is used
KP          = 0.006275604;               % [s] detuned gains
KI          = 0.0008965149;              % [-]
                  
Parameter.CPC.kp                  = KP;                                % [s]
Parameter.CPC.Ti                  = KP/KI;                             % [s] 
Parameter.CPC.theta_K             = deg2rad(6.302336);                 % [rad]
Parameter.CPC.Omega_g_rated       = Parameter.Turbine.Omega_rated/Parameter.Turbine.i;  % [rad/s]
Parameter.CPC.theta_max           = Parameter.PitchActuator.theta_max; % [rad]
Parameter.CPC.theta_min           = Parameter.PitchActuator.theta_min; % [rad]


%% Additional user parameters may be put here depending on the user's Simulink model
% NOTE: Below are the values needed for the NREL5MW_Example_IPC.mdl. You may comment them.
Parameter.CPC.k      = 11        ; % [s]
Parameter.CPC.fl     = 0.2       ; % [s]
Parameter.CPC.fh     = 2.0       ; % [s]
Parameter.IPC.numG11 = -3.0715E-8; % [s]
Parameter.IPC.denG11 = 1.0       ; % [s]
Parameter.IPC.numG12 = 0.0       ; % [s]
Parameter.IPC.denG12 = 1.0       ; % [s]
Parameter.IPC.numG21 = 0.0       ; % [s]
Parameter.IPC.denG21 = 1.0       ; % [s]
Parameter.IPC.numG22 = -3.0715E-8; % [s]
Parameter.IPC.denG22 = 1.0       ; % [s]
% <<<
% <<<
% <<<
% <<<


end
