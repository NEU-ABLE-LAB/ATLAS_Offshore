function mlc=evaluate_population(mlc,n)
% EVALUATE_POPULATION evolves the population. (MLC2 Toolbox)
%
% OBJ.EVALUATE_POPULATION launches the evaluation method, and updates the 
%    MLC2 object.
%
%   The evaluation algorithm is implemented in the <a href="matlab:help MLCpop">MLCpop</a> class.
%
%   See also MLCPARAMETERS, MLCPOP
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

 
   if nargin<2
       n=length(mlc.population); % starting from a different generation is 
                                 % a dev option, thus undocumented.
                                 % it can possibly break the object
                                 % interpretation or functioning.
   end
   
    %% Evaluate the whole population
    idx=1:length(mlc.population(n).individuals);
    [mlc.population(n), mlc.table] = ...
        mlc.population(n).evaluate(mlc.table, mlc.parameters, idx);
    
    if mlc.parameters.save==1
        save(fullfile(mlc.parameters.savedir, ...
            [datestr(now,'YYYYmmDD_HHMMSS') 'mlc_de.mat']),'mlc')
    end
    
    %% remove bad individuals
    elim=0;
    switch mlc.parameters.badvalues_elim
        case 'first'
            if n==1
                elim=1;
            end
        case 'all'
            elim=1;
    end
    
    if elim==1
        
        [mlc.population(n), idx] = ...
            mlc.population(n).remove_bad_indivs(mlc.parameters);
        cullingN = 1;
        
        while ~isempty(idx)
            
            [mlc.population(n), mlc.table] = ...
                mlc.population(n).create(mlc.parameters,mlc.table);
            
            [mlc.population(n), mlc.table] = ...
                mlc.population(n).evaluate(mlc.table, mlc.parameters,idx);
            
            [mlc.population(n), idx] = ...
                mlc.population(n).remove_bad_indivs(mlc.parameters);
            
            cullingN = cullingN + 1;
			
            if mlc.parameters.save==1
              save(fullfile(mlc.parameters.savedir,[datestr(now,'YYYYmmDD_HHMMSS') 'mlc_cull.mat']),'mlc')
            end
        end
    end
    
    %% Sort population
    mlc.population(n).sort(mlc.parameters);
    
    %% Enforced Re-evaluation
    if mlc.parameters.ev_again_best
        for i=1:mlc.parameters.ev_again_times
            idx=1:mlc.parameters.ev_again_nb;
            [mlc.population(n),mlc.table] = ...
                mlc.population(n).evaluate(mlc.table,mlc.parameters,idx);
            mlc.population(n).sort(mlc.parameters);
        end
    end
    mlc.population(n).state='evaluated';
        
    %% Update case difficulty, specific to this analysis
    %Update case dificulty for this case
    if strcmpi(mlc.parameters.problem_variables.eval_type, 'case_difficulty')
        caseid = strcmp(mlc.parameters.problem_variables.runCases,mlc.population(n).caseN{1});
        caseid = find(caseid,1);
        mlc.parameters.problem_variables.caseDifficulty(caseid) = ...
            mean( mlc.population(n).costs(1:round(end*mlc.parameters.probrep*2)));
    end
    
    %% update champion individuals
    if mlc.parameters.champions>0
        for jj = 1 : mlc.parameters.champions
           mlc.population(n).champions(jj,caseid) = mlc.population(n).individuals(1,jj);
        end    
    end
        
end        
    