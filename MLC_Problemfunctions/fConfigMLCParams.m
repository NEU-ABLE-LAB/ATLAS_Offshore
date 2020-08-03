function [MLC_Params] = fConfigMLCParams(problem_variables)
%% GP problem parameters            % (data type)[default] Description

MLC_Params.sensors=...              %*(num)[1]$N_s$ Number of sensors               outlist sensors +3 states
    problem_variables.nSensors + problem_variables.nStates;
MLC_Params.sensor_spec=0;           % ?(bool)[0] Is a sensor list provided
MLC_Params.controls= ...            %*(num)[1]$N_b$ Number of controls             
    3 + problem_variables.nStates;  
MLC_Params.sensor_prob=0.33;        % (num)[0.33] Probability of adding a sensor (vs constant) when creating leaf
MLC_Params.leaf_prob=0.3;           % (num)[0.3] Probability of creating a leaf (vs adding operation) 
MLC_Params.range=10;                %*(num)[10] New constants in GP will be drawn from +/- this range
MLC_Params.precision=4;             % (num)[4] Maximum number of significant digits of new constants
MLC_Params.opsetrange=1:7;          % (array)[1:9] An array specifying the mathematical operations used by the GP, as specified in `opset.m`
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
MLC_Params.individual_type='tree';  % (str)['tree'] The only acceptable type is 'tree'


%% GP algorithm parameters  % (data type)[default] Description
% (CHANGE IF YOU KNOW WHAT YOU DO)
MLC_Params.maxdepth=15;              % (num)[15] Maximum depth of program tree
MLC_Params.maxdepthfirst=5;          % (num)[5] 
MLC_Params.mindepth=2;               % (num)[2] Minimum depth of program tree
MLC_Params.mutmaxdepth=15;           % (num)[15] 
MLC_Params.mutmindepth=2;            % (num)[2]
MLC_Params.mutsubtreemindepth=2;     % (num)[2]
MLC_Params.generation_method=...     % (str)['mixed_ramped_gauss'] The method of generating tree
    'mixed_ramped_gauss';   %   'random_maxdepth' - 
                            %   'fixed_maxdepthfirst' 
                            %   'random_maxdepthfirst'
                            %   'full_maxdepthfirst'
                            %   'mixed_maxdepthfirst' 
                            %   'mixed_ramped_even' - 
                            %   'mixed_ramped_gauss' -
                            %   SEE: Duriez 2017 pg 25
MLC_Params.gaussigma=3;              % (num)[3] The variance?? for the 'mixed_ramped gauss' generation method
MLC_Params.ramp=2:8;                 % (array)[2:8]
MLC_Params.maxtries=10;              % (num)[10]
MLC_Params.mutation_types=1:4;       % (array)[1:4]


%% Optimization parameters     % (data type)[default] Description
MLC_Params.elitism=10;                  %*(num)[10]$N_e$ Number of best individuals to carry over to next generation
MLC_Params.probrep=0.1;                 %*(num)[0.1]$P_r$ Probability of replication
MLC_Params.probmut=0.5;                 %*(num)[0.4]$P_m$ Probability of mutation
MLC_Params.probcro=0.4;                 %*(num)[0.5]$P_c$ Probability of crossover
MLC_Params.selectionmethod='tournament';% (str)['tournament'] The only acceptable type is 'tournament'
MLC_Params.tournamentsize=7;            % (num)[7]$N_p$ The number of individuals that enter the tournament
MLC_Params.lookforduplicates=1;         % (bool)(1) Remove (strict) duplicates 
MLC_Params.simplify=0;                  % (bool)(0) Simplify LISP expressions
MLC_Params.cascade=[1 1];               % (array)[1 1] Sets `obj.subgen` properties. See `MLCop.m`


%% Evaluator parameters           % (data type)[default] Description
MLC_Params.evaluation_method=...        %*(str)['mfile_standalone'] Evaluation method, choose one:
...     'mfile_standalone';       %   `mfile_standalone` Compute serial
    'mfile_multi';                %   `mfile_multi` Compute in parallel

MLC_Params.nCases=12;                   %*(num)[1] The number different design cases that a population could be subjected to

MLC_Params.ev_again_times=1;            % ?(num)[5] The number of times to reevaluate best individuals
MLC_Params.execute_before_evaluation='';% (expr)[''] A Matlab expression to be evaluated with `eval()` before evaluation.
MLC_Params.badvalue=1000;               %*(num)[1E36] The value to return when `evaluation_function` determines the controller is 'bad'
MLC_Params.badvalues_elim='all';        % (str)['first'] When should bad individuals be eliminated
                               %   'none' Never remove bad individuals
                               %   'first' Only remove bad individuals in the first generation
                               %   'all' Remove bad individuals during all generations
MLC_Params.preevaluation=1;             %*(bool)[0] Should individuals be pre-evaluated

if exist('initialPop','var') && ~isempty(initialPop)
	MLC_Params.initialPop = initialPop;
end

%% MLC behavior parameters     % (data type)[default] Description
MLC_Params.save=1;                      % (bool)[1] Should populations be saved to `mlc_be.mat` every time they're created and to `mlc_ae.mat` after evaluation
MLC_Params.savedir=...                  % (str)[fullfile(pwd,'save_GP')] The directory to save files to
    [pwd '/save_GP'];   
MLC_Params.saveincomplete=1;            % ?(bool)[1] Should incomplete evaulations be saved
MLC_Params.verbose=2;                   % (num)[2] Level of verbose output: `0`, `1`, `2`, ...

% Add problem variables
MLC_Params.problem_variables = problem_variables;



end

