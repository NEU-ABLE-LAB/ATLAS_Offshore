classdef MLCpop < handle
  % copyright  
    properties
        individuals % A vector of the index where to find each individual in MLCtable
        costs       % A vector of the cost for each individual in this generation
        gen_method  % A vector of enums that specify the generation method
        parents     % A cell vector list each the individual's parents
        state       % The state of evaluation of the  population
        gen         % The generation of the population
        subgen      % The sub-generation of the population
        caseN       % The design case used to evaluate population
    end
    
    methods
        [obj,mlctable]=create(obj,mlc_parameters,mlctable);
        [obj2,mlctable]=evolve(obj,mlc_parameters,mlctable,mlcpop2);
  %      indexes=select(obj,mlc_parameters);
        [obj,mlctable]=evaluate(obj,mlctable,mlc_parameters,idx);
        obj=sort(obj,mlc_parameters);        
        [obj,idx]=remove_bad_indivs(obj,mlc_parameters);
        [obj]=remove_duplicates(obj);
        obj=remove_individual(obj,idx);
        
        function obj=MLCpop(mlc_parameters,gen,caseN)
        
            if nargin<2
                gen=1;
            end
            obj.gen=gen;
            
            if mod(gen,mlc_parameters.cascade(2))==0
                obj.subgen=1;
            else
                obj.subgen=mlc_parameters.cascade(1);
            end
            
            if length(mlc_parameters.size)>1 && gen>1
                gensize=mlc_parameters.size(2);
            else
                gensize=mlc_parameters.size(1);
            end    
            obj.individuals=zeros(1,gensize)-1;
            obj.costs=zeros(1,gensize)-1;
            obj.gen_method=zeros(1,gensize)-1;
            obj.parents=cell(1,gensize);
            obj.state='init';
            if exist('caseN','var') && ~isempty(caseN)
                obj.caseN = caseN;
            else
                obj.caseN = 1;
            end
        end
    end
end
        
    










