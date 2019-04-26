function [mlcpop,mlctable]=evaluate(mlcpop,mlctable,mlc_parameters,eval_idx)
% copyright
    verb=mlc_parameters.verbose;
    ngen=mlcpop.gen;
    %% If present, execute_before_evaluation
    if ~isempty(mlc_parameters.execute_before_evaluation)
        eval(mlc_parameters.execute_before_evaluation);
    end
        
    %% Determine individuals to evaluate
    idv_to_evaluate=mlcpop.individuals(eval_idx);
    JJ=zeros(1,length(idv_to_evaluate));
    date_ev=JJ;
    if verb>0;fprintf('Evaluation of generation %d\n',ngen);end
    if verb>1;fprintf(['Evaluation method: "' mlc_parameters.evaluation_method '"\n']);end
    %% Check if method was interrupted
    if exist(fullfile(mlc_parameters.savedir,'MLC_incomplete.mat'),'file') && ...
            mlc_parameters.saveincomplete==1
        
        ic=0;
        load(fullfile(mlc_parameters.savedir,'MLC_incomplete.mat'),'JJ','ic');
        istart=ic;
    else
        istart=1;
    end

    %% Beginning method dependent evaluation

    switch mlc_parameters.evaluation_method
        case 'test'
            for i=istart:length(eval_idx)
                if mlc_parameters.saveincomplete==1
                    ic=i;
                    save(fullfile(mlc_parameters.savedir,'MLC_incomplete.mat'),'JJ','ic');
                end
                if verb>1;fprintf('Individual %i from generation %i\n',eval_idx(i),ngen);end
                if verb>2;fprintf('%s\n',mlctable.individuals(idv_to_evaluate(i)).value);end
                JJ(i)=rand+(rand<0.1)*10^50;
            end
            
        case 'mfile_multi'
            
            eval(['heval=@' mlc_parameters.evaluation_function ';']);
            f=heval;
            
            nidx=length(eval_idx);
            parForIndvs = mlctable.individuals;
            
            pp = gcp();
            ppm = ParforProgMon(...
                sprintf('MLCpop.evaluate - gen %i - %i idv: ', ...
                    ngen, (nidx-istart+1)), ...
                (nidx-istart+1), 1,1200,160);
            
            parfor i=istart:nidx
                               
                if verb>3
                    fprintf('Individual %i from generation %i\n',...
                        eval_idx(i),ngen)
                end
                if verb>4
                    fprintf('%s\n',...
                        parForIndvs(idv_to_evaluate(i)).value)
                end
                
                %retrieve object in the table
                m=parForIndvs(idv_to_evaluate(i));
                
                JJ(i)=feval(f,m,mlc_parameters,i);
                date_ev(i)=now;
                
                ppm.increment();
                
            end
            
            % Clean up temporary Simulink files
            % Close all Simulink system windows unconditionally
            bdclose('all')
            % Clean up worker repositories
            Simulink.sdi.cleanupWorkerResources
            % https://www.mathworks.com/matlabcentral/answers/385898-parsim-function-consumes-lot-of-memory-how-to-clear-temporary-matlab-files
            parfevalOnAll(gcp, @sdi.Repository.clearRepositoryFile, 0)
            
        case 'mfile_standalone'
        eval(['heval=@' mlc_parameters.evaluation_function ';']);
        f=heval;
        for i=istart:length(eval_idx)
            if mlc_parameters.saveincomplete==1
                ic=i;
                save(fullfile(mlc_parameters.savedir,'MLC_incomplete.mat'),'JJ','ic');
            end
            if verb>1;fprintf('Individual %i from generation %i\n',eval_idx(i),ngen);end
            if verb>2;fprintf('%s\n',mlctable.individuals(idv_to_evaluate(i)).value);end
            %retrieve object in the table
            m=mlctable.individuals((idv_to_evaluate(i)));
            JJ(i)=feval(f,m,mlc_parameters,i);
            date_ev(i)=now;
        end
            
            
    end

    %% End of effective evaluation
    if  mlc_parameters.saveincomplete==1 && ~strcmp(mlc_parameters.evaluation_method,'multithread_function');
        delete(fullfile(mlc_parameters.savedir,'MLC_incomplete.mat'));
    end


    %% MLCtable update
    if verb>0;fprintf('Updating database\n');end
    for i=1:length(eval_idx);
        if verb>2;fprintf('Individual %i from generation %i\n',eval_idx(i),ngen);end
        if verb>2;fprintf('%s\n',mlctable.individuals(idv_to_evaluate(i)).value);end
        J=JJ(i);
        %% Checking numerical value
        if isnan(J) || isinf(J)
            if verb>4;fprintf('That''s a NaN !\n');end
            J=mlc_parameters.badvalue;
        elseif J>mlc_parameters.badvalue
            J=mlc_parameters.badvalue;
        end
      %  save test idv_to_evaluate
        mlctable.update_individual(idv_to_evaluate(i),J);
        mlcpop.costs(eval_idx(i))=mlctable.individuals(idv_to_evaluate(i)).cost;
    end
end
















