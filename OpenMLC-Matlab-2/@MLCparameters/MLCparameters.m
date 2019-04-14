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
    size            %*(num)[1000]$N_i$ Population size
    sensors         % (num)[1]$N_s$ Number of sensors
    sensor_spec     % (bool)[0] Is a sensor list provided?
    sensor_list     % ??? (`sensors`x1 num)[] Numbering system for sensors
    controls        % (num)[1]$N_b$ Number of controls
    sensor_prob     % (num)[0.33] Probability of adding a sensor (vs constant) when creating leaf
    leaf_prob       % (num)[0.3] Probability of creating a leaf (vs adding operation) 
    range           % (num)[10] New constants in GP will be drawn from +/- this range
    precision       % (num)[4] Maximum number of significant digits of new constants
    opsetrange      % (array)[1:9] An array specifying the mathematical operations used by the GP, as specified in `opset.m`
    opset           % AUTO(struct)[opset(properties.range)] The set of mathematical operations used by the genetic program. See `opset.m`
    formal          % ??? Never referenced in code
    end_character   % ??? Never referenced in code
    individual_type % (str)['tree'] The only acceptable type is 'tree'
    
    maxdepth            % (num)[15] Maximum depth of program tree
    maxdepthfirst       % (num)[5] 
    mindepth            % (num)[2] Minimum depth of program tree
    mutmaxdepth         % (num)[15] 
    mutmindepth         % (num)[2]
    mutsubtreemindepth  % (num)[2]
    generation_method   % (str)['mixed_ramped_gauss'] The method of generating tree
                        %   'random_maxdepth' - 
                        %   'fixed_maxdepthfirst' - 
                        %   'random_maxdepthfirst' - 
                        %   'full_maxdepthfirst'
                        %   'mixed_maxdepthfirst' - 50% at full, 50% random, at maxdepthfirst
                        %   'mixed_ramped_even' - 50% full, 50% random with ramped depth
                        %   'mixed_ramped_gauss' - 50% full 50% random gaussian distrib
                        %   SEE: Duriez 2017 pg 25
    gaussigma           % (num)[3] The variance?? for the 'mixed_ramped gauss' generation method
    ramp                % (array)[2:8]
    maxtries            % (num)[10]
    mutation_types      % (array)[1:4]
    
    elitism             %*(num)[10]$N_e$ Number of best individuals to carry over to next generation
    probrep             %*(num)[0.1]$P_r$ Probability of replication
    probmut             %*(num)[0.4]$P_m$ Probability of mutation
    probcro             %*(num)[0.5]$P_c$ Probability of crossover
    selectionmethod     % (str)['tournament'] The only acceptable type is 'tournament'
    tournamentsize      % (num)[7]$N_p$ The number of individuals that enter the tournament
    lookforduplicates   % (bool)(1) Remove (strict) duplicates 
    simplify            % (bool)(0) Simplify LISP expressions
    cascade             % (array)[1 1] Sets `obj.subgen` properties. See `MLCop.m`

   
    evaluation_method           %*(str)['mfile_standalone'] Evaluation method: 
                                %   serial (`mfile_standalone`) 
                                %   parallel (`mfile_multi`)
    evaluation_function         %*(expr)['toy_problem'] Cost function name. `J=evalFun(ind,mlc_parameters,i,fig)`
    indfile                     % ??? Never referenced in code. (str)['ind.dat'] 
    Jfile                       % ??? Never referenced in code. (str)['J.dat'] 
    exchangedir                 % ??? Never referenced in code. (str)[fullfile(pwd,'evaluator0')] 
    evaluate_all                % ??? Never referenced in code. (bool)[0] 
    ev_again_best               %*(bool)[0] Should elite individuals be reevaluated
    ev_again_nb                 % ?(num)[5] Number off best individuals to reevaluate. Should probably be similar to `elitism`.
    ev_again_times              % ?(num)[5] The number of times to reevaluate best individuals
    artificialnoise             % ??? Never referenced in code. (bool)[0] 
    execute_before_evaluation   % (expr)[''] A Matlab expression to be evaluated with `eval()` before evaluation.
    badvalue                    %*(num)[1E36] The value to return when `evaluation_function` determines the controller is 'bad'
    badvalues_elim              % (str)['first'] When should bad individuals be eliminated
                                %   'none' Never remove bad individuals
                                %   'first' Only remove bad individuals in the first generation
                                %   'all' Remove bad individuals during all generations
    preevaluation               % (bool)[0] Should individuals be pre-evaluated
    preev_function              % (expr)[''] A Matlab expression to be evaluated with `eval()` to pre-evalute an individual
                                %   Expression should return `1` if pre-evaluation identified a valid individual
                                
    save              % (bool)[1] Should populations be saved to `mlc_be.mat` every time they're created and to `mlc_ae.mat` after evaluation
    savedir           % (str)[fullfile(pwd,'save_GP')] The directory to save files to
    saveincomplete    % ?(bool)[1] Should incomplete evaulations be saved
    verbose           % (num)[2] Level of verbose output: `0`, `1`, `2`, ...
    fgen              % ??? Never referenced in code. (num)[250] 
    show_best         % ??? Never referenced in code. (bool)[1]
    problem_variables % (struct)[] A structure of data/variables to pass to `evaluation_function`
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
        %% Call defaults
        mlcdir=which('MLCparameters');
        idx=strfind(mlcdir,'@MLCparameters');
        mlcdir=mlcdir(1:idx-1);
        run(fullfile(mlcdir,'@MLCparameters','private','MLCparameters_default.m'));

        %% Call configuration script if present
        if nargin==1
            fprintf(1,'%s\n',filename);
            run(filename)
        
        end
        
        
        parameters.savedir=fullfile(parameters.savedir,datestr(now,'yyyymmdd-HHMM'));
        [s,mess,messid] = mkdir(parameters.savedir);
        if s==1
            clear s;clear mess;clear messid;
        else
           fprintf('%s',mess);
        end

    end
end
end













