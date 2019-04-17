classdef MLCparameters < handle
%SET_MLCPARAMETERS   Function for the constructor the MLC Class. Sets default values and calls parameters script.
%  PARAMETERS=set_MLC_parameters returns a pre-structure of parameters for
%  the MLC Class, with default values. (solves 'toy_problem').
%  PARAMETERS=set_MLC_parameters(FILENAME) returns a pre-structure of 
%  parameters for the MLC Class with default values overriden by
%  instructions in the FILENAME M-script. Ex: <a href="matlab:help GP_lorenz">GP_lorenz.m</a>
%
%   Copyright (C) 2015-2017 Thomas Duriez.
%   This file is part of the OpenMLC-Matlab-2 Toolbox. Distributed under GPL v3.

%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.

properties % (data type)[default] Description
                         % (data type)[default] Description
                                    
    %% GP problem parameters
    size=1000;               %*(num)[1000]$N_i$ Population size
    sensors=1;               %*(num)[1]$N_s$ Number of sensors
    sensor_spec=0;           % ?(bool)[0] Is a sensor list provided
    controls=1;              %*(num)[1]$N_b$ Number of controls
    sensor_prob=0.33;        % (num)[0.33] Probability of adding a sensor (vs constant) when creating leaf
    leaf_prob=0.3;           % (num)[0.3] Probability of creating a leaf (vs adding operation) 
    range=10;                %*(num)[10] New constants in GP will be drawn from +/- this range
    precision=4;             % (num)[4] Maximum number of significant digits of new constants
    opsetrange=1:9;          % (array)[1:9] An array specifying the mathematical operations used by the GP, as specified in `opset.m`
    individual_type='tree';  % (str)['tree'] The only acceptable type is 'tree'


    %% GP algorithm parameters (CHANGE IF YOU KNOW WHAT YOU DO)
    maxdepth=15;           % (num)[15] Maximum depth of program tree
    maxdepthfirst=5;       % (num)[5] 
    mindepth=2;            % (num)[2] Minimum depth of program tree
    mutmaxdepth=15;        % (num)[15] 
    mutmindepth=2;         % (num)[2]
    mutsubtreemindepth=2;  % (num)[2]
    generation_method=...  % (str)['mixed_ramped_gauss'] The method of generating tree
        'mixed_ramped_gauss';         %   'random_maxdepth' - 
                                      %   'fixed_maxdepthfirst' 
                                      %   'random_maxdepthfirst'
                                      %   'full_maxdepthfirst'
                                      %   'mixed_maxdepthfirst' 
                                      %   'mixed_ramped_even' - 
                                      %   'mixed_ramped_gauss' -
                                      %   SEE: Duriez 2017 pg 25
    gaussigma=3;           % (num)[3] The variance?? for the 'mixed_ramped gauss' generation method
    ramp=2:8;              % (array)[2:8]
    maxtries=10;           % (num)[10]
    mutation_types=1:4;    % (array)[1:4]


    %% Optimization parameters
    elitism=10;                  %*(num)[10]$N_e$ Number of best individuals to carry over to next generation
    probrep=0.1;                 %*(num)[0.1]$P_r$ Probability of replication
    probmut=0.4;                 %*(num)[0.4]$P_m$ Probability of mutation
    probcro=0.5;                 %*(num)[0.5]$P_c$ Probability of crossover
    selectionmethod='tournament';% (str)['tournament'] The only acceptable type is 'tournament'
    tournamentsize=7;            % (num)[7]$N_p$ The number of individuals that enter the tournament
    lookforduplicates=1;         % (bool)(1) Remove (strict) duplicates 
    simplify=0;                  % (bool)(0) Simplify LISP expressions
    cascade=[1 1];               % (array)[1 1] Sets `obj.subgen` properties. See `MLCop.m`

    %% Evaluator parameters 
    evaluation_method=...        %*(str)['mfile_standalone'] Evaluation method: 
        'mfile_standalone';                 %   serial (`mfile_standalone`) 
                                            %   parallel (`mfile_multi`)
    evaluation_function=...      %*(expr)['toy_problem'] Cost function name. 
        'toy_problem';                      %   `J=evalFun(ind,mlc_parameters,i,fig)`
    ev_again_best=0;             %*(bool)[0] Should elite individuals be reevaluated
    ev_again_nb=5;               % ?(num)[5] Number off best individuals to reevaluate. Should probably be similar to `elitism`.
    ev_again_times=5;            % ?(num)[5] The number of times to reevaluate best individuals
    execute_before_evaluation='';% (expr)[''] A Matlab expression to be evaluated with `eval()` before evaluation.
    badvalue=10^36;              %*(num)[1E36] The value to return when `evaluation_function` determines the controller is 'bad'
    badvalues_elim='first';      % (str)['first'] When should bad individuals be eliminated
                                            %   'none' Never remove bad individuals
                                            %   'first' Only remove bad individuals in the first generation
                                            %   'all' Remove bad individuals during all generations
    preevaluation=0;             % (bool)[0] Should individuals be pre-evaluated
    preev_function='';           % (expr)[''] A Matlab expression to be evaluated with `eval()` to pre-evalute an individual
                                            %   Expression should return `1` if pre-evaluation identified a valid individual

    problem_variables=struct();  % (struct)[] A structure of data/variables to pass to `evaluation_function`

    %% MLC behavior parameters              
    save=1;                      % (bool)[1] Should populations be saved to `mlc_be.mat` every time they're created and to `mlc_ae.mat` after evaluation
    savedir=...                  % (str)[fullfile(pwd,'save_GP')] The directory to save files to
        fullfile(pwd,'save_GP');            % ?(bool)[1] Should incomplete evaulations be saved
    saveincomplete=1;            %
    initialPop='';               % (str)[''] Path to `mlcpop` and `mlctable` with initial populations
    verbose=2;                   % (num)[2] Level of verbose output: `0`, `1`, `2`, ...
end

properties
    opset % The set of mathematical operations used by the genetic program. See `opset.m`
end

properties (SetAccess = private, Hidden)  
    badvalues_elimswitch=1;
    dispswitch=0;
end

methods
    function parameters=elimswitch(parameters,value)
        parameters.badvalues_elimswitch=value;
    end
    function parameters=disp_switch(parameters,value)
        parameters.dispswitch=value;
    end
    
    %% Constructor
    function parameters=MLCparameters(filename)

        %% Read parameters
        if nargin==1 && ischar(filename) && exist(filename,'file')
            % Call configuration script if present
            fprintf(1,'%s\n',filename);
            run(filename)
        elseif nargin==1 && isstruct(filename)
            % Structure of paramters given
            fields = fieldnames(filename);
            for fieldN = 1:length(fields)
                parameters.(fields{fieldN}) = filename.(fields{fieldN});
            end
        end
        
        
        parameters.savedir=fullfile(parameters.savedir,datestr(now,'yyyymmdd-HHMM'));
        [s,mess,~] = mkdir(parameters.savedir);
        if s==1
            clear s;clear mess;clear messid;
        else
           fprintf('%s',mess);
        end

    end
end
end













