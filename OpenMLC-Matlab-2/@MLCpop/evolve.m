function [mlcpop2,mlctable]=evolve(mlcpop,mlc_parameters,mlctable,mlcpop2)
% copyright
    ngen=mlcpop.gen;         
    verb=mlc_parameters.verbose;
	
    if nargin<4
        % Find the hardest case to test the generation on
        [~,caseN] = max(mlctable.caseDifficulty);
    
        % Initialize the next generation
        mlcpop2=MLCpop(mlc_parameters,ngen+1,caseN);
    end
    
    if verb>0;fprintf('Evolving population\n');end
    
    idxsubgen=subgen(mlcpop,mlc_parameters);
    idxsubgen2=subgen(mlcpop2,mlc_parameters);
    
    for i=1:length(idxsubgen2)
        
        idxsubgen2{i}=idxsubgen2{i}(mlcpop2.individuals(idxsubgen2{i})==-1);
		
        if verb>0
            fprintf('Evolving sub-population %i/%i\n',...
                i, mlcpop2.subgen)
        end
		
        if length(idxsubgen)==1
            idx_source_pool=idxsubgen{1};
        else
            idx_source_pool=idxsubgen{i};
        end
        individuals_created=0;
        
        %% elitism
        if nargin < 4
            for i_el=1:ceil(mlc_parameters.elitism/length(idxsubgen2))
            
                idv_orig=idx_source_pool(i_el);
                idv_dest=idxsubgen2{i}(individuals_created+1);
                
                mlcpop2.individuals(idv_dest) = ...
                    mlcpop.individuals(idv_orig);
                    
                mlcpop2.costs(idv_dest) = ...
                    mlcpop.costs(idv_orig);
                    
                mlcpop2.parents{idv_dest} = idv_orig;
                
                mlcpop2.gen_method(idv_dest) = 4;
                
                mlctable.individuals(...
                    mlcpop.individuals(idv_orig)).appearences = ...
                        mlctable.individuals(...
                            mlcpop.individuals(idv_orig)).appearences+1;
                            
                individuals_created=individuals_created+1;
                
            end
        end
        
        %% Determine operations to use
        ops = {};
        indNums = {};
        nOps = 0;
        while individuals_created<length(idxsubgen2{i})
        
            nOps = nOps + 1;
        
            ops{nOps} = choose_genetic_op(...
                mlc_parameters, ...
                length(idxsubgen2{i})-individuals_created);
                
            switch ops{nOps}
                case 'replication'
                    individuals_created = individuals_created+1;
                    indNums{nOps} = individuals_created;
                case 'mutation'
                    individuals_created = individuals_created+1;
                    indNums{nOps} = individuals_created;
                case 'crossover'
                    individuals_created = individuals_created+2;
                    indNums{nOps} = [-1 0] + individuals_created;
            end
                
        end
        
        %% Perform genetic operations
        
        % Replicate 
        for opN = find(contains(ops,'replication'))
        
            idv_orig = choose_individual(...
                mlcpop,mlc_parameters,idx_source_pool);
            
            idv_dest = idxsubgen2{i}(indNums{opN});
            
            mlcpop2.individuals(idv_dest) = ...
                mlcpop.individuals(idv_orig);
            
            mlcpop2.costs(idv_dest) = mlcpop.costs(idv_orig);
            
            mlcpop2.parents{idv_dest} = idv_orig;
            
            mlcpop2.gen_method(idv_dest)=1;
            
            mlctable.individuals(...
                mlcpop.individuals(...
                    idv_orig)).appearences = ...
                        mlctable.individuals(...
                            mlcpop.individuals(idv_orig)).appearences+1;
            
        end
        
        % Prepare variables for parallel mutation and crossover operations
        gcp();
        ppm = ParforProgMon(...
            sprintf('MLCpop.evolve - pop(%i/%i) - %i Ops @ %s : ', ...
                i, mlcpop2.subgen, nOps, datestr(now,'HH:MM')), ...
            nOps, 1,1200,160);
        mlctable_individuals = mlctable.individuals;
        
        idv_orig  = cell(nOps,1);
        idv_orig2 = cell(nOps,1);
        idv_dest  = cell(nOps,1);
        idv_dest2  = cell(nOps,1);
        new_ind   = cell(nOps,1);
        new_ind2  = cell(nOps,1);
        parfor opN = 1:nOps
            
            switch ops{opN}
                    
                case 'mutation'
                
                    fail=1;
                    while fail==1
                    
                        idv_orig{opN} = ...
                            choose_individual(mlcpop, ...
                                mlc_parameters, idx_source_pool);
                                
                        idv_dest{opN} = idxsubgen2{i}(...
                            indNums{opN});
                        
                        old_ind = mlctable_individuals(...
                            mlcpop.individuals(...
                                idv_orig{opN}));
                                
                        [new_ind{opN}, fail] = ...
                            old_ind.mutate(mlc_parameters);   

                        if ~new_ind{opN}.preev(mlc_parameters) 
                            fail = 1;
                        end
                    end
                    
                case 'crossover'
                    
                    fail=1;
                    while fail==1
                    
                        idv_orig{opN} = choose_individual(...
                            mlcpop,mlc_parameters,idx_source_pool);
                            
                        idv_orig2{opN} = idv_orig{opN};
                        
                        while idv_orig2{opN}==idv_orig{opN}
                            idv_orig2{opN} = choose_individual(...
                                mlcpop,mlc_parameters,idx_source_pool);
                        end
                        
                        idv_dest{opN} = idxsubgen2{i}( ...
                            indNums{opN}(1));
                        
                        idv_dest2{opN} = idxsubgen2{i}(...
                            indNums{opN}(2));
                        
                        old_ind = mlctable_individuals(...
                            mlcpop.individuals(idv_orig{opN}));
                            
                        old_ind2 = mlctable_individuals(...
                            mlcpop.individuals(idv_orig2{opN}));
                            
                        [new_ind{opN}, new_ind2{opN}, fail] = ...
                            old_ind.crossover(old_ind2,mlc_parameters);
                        
                        if  ~( new_ind{opN}.preev(mlc_parameters) && ...
                                new_ind2{opN}.preev(mlc_parameters) )
                            fail = 1;
                        end
                    end
                    
            end
            
            ppm.increment(); %#ok<PFBNS>
        end

        % Clean up temporary Simulink files
        % Close all Simulink system windows unconditionally
        bdclose('all')
        % Clean up worker repositories
        Simulink.sdi.cleanupWorkerResources
        % https://www.mathworks.com/matlabcentral/answers/385898-parsim-function-consumes-lot-of-memory-how-to-clear-temporary-matlab-files
        parfevalOnAll(gcp, @sdi.Repository.clearRepositoryFile, 0)
        
        % Add mutated and crossover individuals
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
    end
    
    
    
    










