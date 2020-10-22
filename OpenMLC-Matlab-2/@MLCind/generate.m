function mlcind=generate(mlcind,mlc_parameters,varargin)
% GENERATE     generates individual from scratch or from unfinished individual.
%
%   MLCIND.generate(MLC_PARAMETERS,MODE) creates an individual f using mode
%          MODE. MODE is a number which interpretation depends on the
%          MLCIND.type propertie. (Not designed to be played with by user, 
%          code dive for details)
%
%   MLCIND.generate(MLC_PARAMETERS,VALUE) creates an individual with
%   MLCIND.value VALUE.
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

switch mlc_parameters.individual_type
    case 'tree'
        mlcind.type='tree';
        mlcind.value=['(root @' repmat(' @',[1 mlc_parameters.controls-1]) ')'];
        type=varargin{1};
        if ~ischar(type)
            for i=1:mlc_parameters.controls
                mlcind.value=generate_indiv_regressive_tree(mlcind.value,mlc_parameters,type);
            end
        else
            mlcind.value=type;
        end
        mlcind.value=simplify_and_sensors_tree(mlcind.value,mlc_parameters);       
        mlcind.formal=readmylisp_to_formal_MLC(mlcind.value,mlc_parameters);
        mlcind.complexity=tree_complexity(mlcind.value,mlc_parameters);
        
        % hashing system reworked to account for controlers without states
        inhash = mlcind.formal;
        nReals = mlc_parameters.controls - mlc_parameters.problem_variables.nStates;
        inhash(1+nReals:mlc_parameters.controls)= [];
        for equation = 1: nReals
            for state = 1 : mlc_parameters.problem_variables.nStates
                UsesState(state,equation) = contains(inhash{equation}, ['S' num2str(mlc_parameters.problem_variables.nSensors + state - 1)]); 
            end
        end
                
        if sum(sum(UsesState)) == 0
            bit32=DataHash(inhash);         % No states called by primary controlers, just hash primary controlers
        else
            bit32=DataHash(mlcind.value);   % States used, hash entire equation
        end
        mlcind.hash=hex2num(bit32(1:16));
        
        
end










