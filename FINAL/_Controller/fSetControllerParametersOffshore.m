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


%% MLC Parameters

Parameter.MLC.gain = 1E-2;
Parameter.sensorsNormOffset = [300	13.4000791772882	-6.56754179752280e-05	2.47426544343831e-05	5.23054411985547	5.23054411985547	5.23054411985547	179.829125488810	12.1875034779334	1182.18062449701	-9.99851854825508	3.49625304797243	-0.596264072841776	0	3.84026587007073	-0.652775997065363	0	4.32715428473914	-0.743596520052692	0	52.8595934049077	52.7955887527135	52.7092851346197	0.000281528967601604	0.000166642687255807	-0.00366548917037101	0.345268748514861	-0.106996608919037	0	19.1203386932507	-2.52471318963985	-0.394294787511345	0.847789159433669	3.86619845371045	0.144596611781315	0.00268001548936232	0.00170972806140240	0.000705029115273706	5.57081762805190e-05	0.000147736295385865	-0.00124368823143299	213.891776172801	-39.0900493119269	619.403246746424	1210.34815189234	7025.47620081180	-21.0670554856745	229.606171310937	-40.6129762080017	616.601486688820	1268.23322150547	7625.81534885951	-13.3311822704578	250.574378003869	-44.6726869343054	612.109796539998	1406.29151998613	8442.53112732957	-3.96125883679275	-76.4049819145713	1716.22664301634	-23.9142346467014	-101.023363360656	1881.66289724211	-20.0875472138579	-119.570674539422	2117.92842298591	-15.3217571343263	-1034.61272655332	-752.944702178515	703.981510799262	-0.406474271596387	8.46970812250131	4069.22866952715	-1018.41830518159	-752.167024800401	5201.74257618036	41.9508104473750	776.440725818606	-150.627142133173	-3461.63160344290	4250.24428961893	313.886168389504	233.309698229283	-0.000171701169231150	0.000227833472154821	949.428427823269	-176.838950421471	-5911.11591623140	16799.6976143330	66716.0337100931	233.579459525772	7101.65662067382	0.00542756564473551	6.31415911306778	0.337889081175432	0.447445192378355	0	4910.04379038845	41.9482412189037	5.23054411985547	5.23054411985547	5.23054411985547	1.08066581670282e-05	632980.472398191	458900.594210144	1204949.32676846	1030894.49698587	1102831.33058814	928802.220047373];
Parameter.sensorNormGain = [173.208689158483	2.18390343068316	1.74481579293432	1.08302612645950	3.42261731441152	3.42261731441152	3.42261731441152	103.827293644280	0.718295317411723	69.7348971788404	0.0115159637567316	1.28010433293584	0.407595485144157	0	1.24701909635011	0.412013137530999	0	1.20486963729097	0.427248435184894	0	16.9407916063416	17.0204714862927	17.0830691786374	0.443741386506445	0.146324586977353	0.0948812015093992	0.118188377772930	0.0324400461835441	0	4.95992713092571	1.14315905135245	0.251894441560761	0.369640746588020	1.20340595004458	0.927700990777284	0.0596282797339579	0.221779803423306	0.286941793418187	0.173677963070773	0.0472281186899307	0.0271336330308049	52.9493898878414	123.791935117271	139.887678296627	2602.31913618884	2044.43268564474	40.7870157585783	52.2818932016852	123.750256316661	140.709727730667	2604.64023233938	1997.98797847542	42.0561536988598	50.4384250749205	124.569991862895	139.945257174771	2632.24151178941	1918.07595290541	45.8029633170104	376.155007147276	621.953773798272	15.8737426311998	376.410040883446	603.584071794943	16.0802122754710	378.789777582697	580.949007133734	16.9565295520579	1660.51659943306	1657.39582951599	145.372318591429	749.299048864322	749.651025385407	356.537906676777	1974.39686431697	2024.27595308568	607.447636650856	3.67564838837092	246.293281810126	67.8177780388267	27.1818641576949	529.947352025361	1857.63287594856	1814.65436513722	0.421070454722244	0.149700865138162	310.862882607632	80.5860109471050	31.4973782948896	6052.13221778712	22267.6405004252	1814.74225127344	2053.94250080626	0.725576957184584	0.620098632422559	0.100821835484220	0.170465973283004	0	538.800703630097	3.28568571264164	3.42261731441152	3.42261731441152	3.42261731441152	0.795112170205531	68515.9754547934	68514.0791006621	107557.849253493	107680.271357012	100975.976176381	101104.344005751];
Parameter.sensorNormGain(isinf(Parameter.sensorNormGain)) = 0;

%% MLC Controller

Parameter.MLC.ctrl = cell(6,1);

Parameter.MLC.ctrl{1} = @(u)((cos((cos((my_div(my_log(((-0.5459) + u(7))),cos((9.911 * (-1.934)))))) - (cos(((5.64 - u(4)) - cos((-1.529)))) - (((my_div(u(5),u(3))) + ((-1.294) * (-3.319))) * (cos((-9.491)) + (1.815 * 3.846)))))) * my_log((my_div(sin(sin(((8.113 * u(5)) - (my_div((-3.274),u(25)))))),cos(my_log(((u(74) - (-5.668)) - (u(74) - u(46))))))))));
Parameter.MLC.ctrl{2} = @(u)(my_log((my_div((my_log(sin(sin(my_log(u(46))))) - sin(my_log(cos(cos(my_log(sin(sin(u(26))))))))),(sin(((my_div((my_div(6.979,(-2.933))),cos(u(47)))) * (sin((-1.702)) - (my_div(u(4),(-6.916)))))) - sin(sin(cos((u(34) * (-0.4034))))))))));
Parameter.MLC.ctrl{3} = @(u)((my_div(((sin(cos(sin((-1.327)))) + sin(sin((0.266 + (-6.804))))) - (my_div(cos((my_div(((-2.181) - 3.533),my_log(u(34))))),sin(cos((8.82 - u(34))))))),sin((my_log(cos((9.535 * 7.438))) - cos((cos((-7.867)) - cos(8.409))))))) + my_log(sin((my_div(sin(((9.515 * (-9.647)) * (my_div(u(46),7.847)))),(my_log(sin(u(7))) * (my_div(((-4.264) - (-0.2901)),my_log(u(24))))))))));
Parameter.MLC.ctrl{4} = @(u)(my_div((sin(((cos(((-1.228) * 8.756)) - my_log((u(99) - u(24)))) * my_log((my_log(2.064) - my_log(0.2148))))) * (sin(((((-6.687) - (-9.336)) * sin(8.851)) * (my_div(sin(u(25)),((-9.121) + 2.803))))) * sin(my_log((my_log(0.5398) + sin(2.307)))))),((my_div((my_log(cos(sin(6.134))) * (my_log(sin((-7.722))) * (my_log((-0.3245)) + ((-2.677) * (-6.922))))),my_log(sin((my_div(my_log(6.591),cos(u(25)))))))) + my_log((my_div(((((-1.719) * 9.314) - cos((-1.156))) + (my_div((u(74) - u(34)),my_log(2.246)))),cos(my_log((u(6) - u(74))))))))));
Parameter.MLC.ctrl{5} = @(u)(((cos((((u(6) + 1.915) + (my_div(u(24),u(3)))) + (my_log(u(99)) * (my_div((-5.656),(-1.208)))))) - (my_div(cos(cos(((my_div((-6.021),(-4.139))) + ((-8.9) + (-2.656))))),(my_log((u(7) - u(91))) + (sin(8.918) - my_log(u(91))))))) + sin((sin(my_log(sin(0.1211))) - ((u(7) * ((-3.19) * (-3.484))) * my_log((7.294 + (-5.509))))))) * sin((my_div(my_log(((sin(u(7)) - (1.388 + (-0.1721))) + (((-1.37) + u(9)) * (u(46) - u(4))))),(my_div((((1.596 * (-6.529)) + (2.923 * 3.235)) - (my_log(u(91)) - (u(74) - 9.278))),cos((cos(2.641) * my_log(6.844)))))))));
Parameter.MLC.ctrl{6} = @(u)(sin(((my_div(sin((my_div((((-9.56) * 8.443) * (my_div((-8.997),(-1.373)))),((my_div((-0.9073),4.364)) + ((-1.865) + u(5)))))),((cos(my_log(u(10))) * (my_div(cos(8.295),(5.977 * u(24))))) - sin(((u(99) * (-4.318)) - (6.972 - (-0.02425))))))) * (cos(my_log((cos((-7.418)) * (my_div(6.554,u(9)))))) + ((((1.658 - u(9)) * (my_div(u(24),u(26)))) + (((-9.696) - (-8.625)) + (3.625 - (-5.931)))) - (my_log((my_div((-4.676),0.6395))) + cos((u(74) + u(91)))))))));
     

end
