 for opN = 1:nOps
        
        switch ops{opN}
            
            case 'mutation'
                
                [mlctable,number] = ...
                    add_individual(mlctable, new_ind{opN});
                
                mlcpop2.individuals(idv_dest{opN}) = number;
                
                mlcpop2.costs(idv_dest{opN}) = -1;
                
                mlcpop2.parents{idv_dest{opN}} = ...
                    idv_orig{opN};
                
                mlcpop2.gen_method(idv_dest{opN}) = 2;
                
                mlctable.individuals(number).appearences = ...
                    mlctable.individuals(number).appearences+1;
                
            case 'crossover'
                
                % Add first individual
                [mlctable, number] = add_individual(...
                    mlctable, new_ind{opN});
                
                mlcpop2.individuals(idv_dest{opN}) = number;
                
                mlcpop2.costs(idv_dest{opN}) = -1;
                
                mlcpop2.parents{idv_dest{opN}} = ...
                    [idv_orig{opN}, ...
                    idv_orig2{opN}];
                
                mlcpop2.gen_method(idv_dest{opN}) = 3;
                
                mlctable.individuals(number).appearences = ...
                    mlctable.individuals(number).appearences+1;
                
                % Add second individual
                [mlctable, number2] = add_individual(...
                    mlctable, new_ind2{opN});
                
                mlcpop2.individuals(idv_dest2{opN}) = number2;
                
                mlcpop2.costs(idv_dest2{opN}) = -1;
                
                mlcpop2.parents{idv_dest2{opN}} = ...
                    [idv_orig{opN}, ...
                    idv_orig2{opN}];
                
                mlcpop2.gen_method(idv_dest2{opN}) = 3;
                
                mlctable.individuals(number2).appearences = ...
                    mlctable.individuals(number2).appearences+1;
                
        end
    end