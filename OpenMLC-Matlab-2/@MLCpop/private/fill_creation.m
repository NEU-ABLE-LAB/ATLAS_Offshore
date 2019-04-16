function [mlcpop,mlctable,i]=fill_creation(mlcpop,mlctable,mlc_parameters,indiv_to_generate,i,type,verb)
% copyright
n_indiv_to_generate=length(indiv_to_generate);
switch mlc_parameters.evaluation_method
    case 'mfile_multi'
        
        indiv_generated = zeros(n_indiv_to_generate,1);
        newInds = cell(n_indiv_to_generate,1);
        
        parfor (newIdvN = 1:n_indiv_to_generate,0)
            isOk = false;
            while ~isOk
                newInds{newIdvN}=MLCind;
                newInds{newIdvN}.generate(mlc_parameters,type);
                isOk = newInds{newIdvN}.preev(mlc_parameters);
                
            end
            disp(sprintf('Generated individual %i\n',indiv_to_generate(newIdvN)))
        end
        
        for newIdvN = 1:n_indiv_to_generate

            already_exist = true;
            
            while already_exist
                
                [mlctable,number,already_exist]=mlctable.add_individual(newInds{newIdvN});
                
                if already_exist
                    while ~isOk
                        newInds{newIdvN}=MLCind;
                        newInds{newIdvN}.generate(mlc_parameters,type);
                        isOk = newInds{newIdvN}.preev(mlc_parameters);
                    end
                end
            end
        end
    
    otherwise
    
        while i<=n_indiv_to_generate
            mlcind=MLCind;
            mlcind.generate(mlc_parameters,type);
            [mlctable,number,already_exist]=mlctable.add_individual(mlcind);
            if already_exist==0
                if verb>1;fprintf('Generating individual %i\n',indiv_to_generate(i));end
                if verb>2;mlcind.textoutput;end
                 
                    if  mlcind.preev(mlc_parameters) 
                        mlcpop.individuals(indiv_to_generate(i))=number;
                        i=i+1;
                    else
                        if verb>1;fprintf('preevaluation fail\n');end
                    end
                
            else
                if verb>3;fprintf('replica\n');end
            end
        end
    end










