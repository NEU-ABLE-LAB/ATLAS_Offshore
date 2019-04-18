function [mlcpop,mlctable,i]=fill_creation(mlcpop,mlctable,mlc_parameters,indiv_to_generate,i,type,verb)
% copyright
n_indiv_to_generate=length(indiv_to_generate);
switch mlc_parameters.evaluation_method
    case 'mfile_multi'
        
        newInds = cell(n_indiv_to_generate,1);
        
		fprintf('Generating %d individuals\n',n_indiv_to_generate);

        pp = gcp();
        ppm = ParforProgMon('MLCpop.fill_creation - generate:', ...
            n_indiv_to_generate);
        
        parfor (newIdvN = 1:n_indiv_to_generate)
            
            isOk = false;
            while ~isOk
                newInds{newIdvN}=MLCind;
                newInds{newIdvN}.generate(mlc_parameters,type);
                isOk = newInds{newIdvN}.preev(mlc_parameters);
                
            end
            fprintf('Generated individual %i\n\n',indiv_to_generate(newIdvN))
            
            ppm.increment();
            
        end
        
        % Variable initialization
        already_exist = true(n_indiv_to_generate,1);
        number = -ones(n_indiv_to_generate,1);
        
        % Replace duplicate individuals
        while any(already_exist)
        
            % Add individuals to mlctable, keeping track if the individual is a duplicate
            for newIdvN = find(already_exist)
            
                [mlctable, number(newIdvN), already_exist(newIdvN)] = ...
                    mlctable.add_individual( newInds{newIdvN} );
                
            end
            
            % Generate new individuals to replace duplicates
            fprintf('Replacing %d duplicate individuals\n\n',...
                sum(already_exist));
                
            pp = gcp();
            ppm = ParforProgMon('MLCpop.fill_creation - exists:', ...
                n_indiv_to_generate);
            
            parfor replaceIndN = find(already_exist)
                
                isOk = false;
                while ~isOk
                    newInds{replaceIndN}=MLCind;
                    newInds{replaceIndN}.generate(mlc_parameters,type);
                    isOk = newInds{replaceIndN}.preev(mlc_parameters);
                end
                
                fprintf('Generated replacement individual %i\n\n',...
                    indiv_to_generate(replaceIndN))
                  
                ppm.increment();
                
            end
        end
        
        for newIdvN = 1:n_indiv_to_generate
            mlcpop.individuals(indiv_to_generate(newIdvN))=number;
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










