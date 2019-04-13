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

 

properties % (data type)(default) Description
    size            % (num)[1000] Population size
    sensors         % (num)[1] Number of sensors
    sensor_spec     % (bool)[0] Is a sensor list provided?
    sensor_list     % ??? (`sensors`x1 num)[] Numbering system for sensors
    controls        % (num)[1] Number of controls
    sensor_prob     % (num)[0.33] Probability of adding a sensor (vs constant) when creating leaf
    leaf_prob       % (num)[0.3] Probability of creating a leaf (vs adding operation) 
    range           % (num)[10] New constants in GP will be drawn from +/- this range
    precision       % (num)[4] Maximum number of significant digits of new constants
    opsetrange      % (array)[1:9] An array specifying the mathematical operations used by the GP, as specified in `opset.m`
    opset           % AUTO(struct)[opset(properties.range)] The set of mathematical operations used by the genetic program. See `opset.m`
    formal          % ??? Never referenced in code
    end_character   % ??? Never referenced in code
    individual_type % (str)['tree'] The only acceptable type is 'tree'
    
    maxdepth            % (num) Maximum depth of program tree
    maxdepthfirst       %
    mindepth            % (num) Minimum depth of program tree
    mutmaxdepth         %
    mutmindepth         %
    mutsubtreemindepth  %
    generation_method   %
    gaussigma           %
    ramp                %
    maxtries            %
    mutation_types      %
    
    elitism             % (num) Number of best individuals to carry over to next generation
    probrep             % (num) Probability of replication
    probmut             % (num) Probability of mutation
    probcro             % (num) Probability of crossover
    selectionmethod     % 
    tournamentsize      % 
    lookforduplicates   % 
    simplify            % 
    cascade             % 

    % Evaluation method: serial (`mfile_standalone`) or parallel (`mfile_multi`)
    evaluation_method           
    
    evaluation_function         % Cost function name. `J=evalFun(ind,mlc_parameters,i,fig)`
    indfile                     %
    Jfile                       % 
    exchangedir                 %
    evaluate_all                %
    ev_again_best               %
    ev_again_nb                 %
    ev_again_times              %
    artificialnoise             %
    execute_before_evaluation   %
    badvalue                    % The value to return when `evaluation_function` determines the controller is 'bad'
    badvalues_elim              %
    preevaluation               %
    preev_function              %
    
    save              % 
    saveincomplete    % 
    verbose           % (num)[2] Level of verbose output: `0`, `1`, `2`, ...
    fgen              % 
    show_best         % 
    problem_variables % (struct)[] A structure of data/variables to pass to `evaluation_function`
end

properties 
    savedir
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













