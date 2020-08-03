classdef MLCtable < handle
    % copyright
    properties
        individuals % An array of the MLCind objects across all generations. 
        hashlist    % A unique hash of each individual
        costlist    % An array of the cost of each individual across all generations
        number      %??The number of the current (next?) individual to create
        caseDifficulty % An array with a difficulty score of each case. (Higher means more difficult.)
    end
    
    methods
        [obj,number,already_exist]=add_individual(obj,mlcind)
        idx=find_individual(obj,mlcind)
        obj=update_individual(obj,idx,J);
  
        function obj=MLCtable(Nind,mlc_parameters)
            if nargin<1
                Nind=50*1000;
            end
            ind=MLCind;
            obj.individuals=repmat(ind,[1,Nind]);
            obj.hashlist=zeros(1,Nind);
            obj.costlist=zeros(1,Nind);
            obj.number=0;
        end
    end
end










