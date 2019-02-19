function fCostFunctionPrint(CF,CF_Comp,CF_Vars,CF_Freq,pMetrics,folders);

    if exist('OCTAVE_VERSION', 'builtin') ~= 0; pkg load statistics; end;

    for i = 1:size(folders,1);
        fprintf('-----------------------------------------------------------------------------\n')
        fprintf('------- Cost function for `%s` \n',folders{i,2})
        fprintf('-----------------------------------------------------------------------------\n')
        fprintCF(CF(i),CF_Comp(i,:),[],CF_Freq{i},pMetrics,folders{i,2});
    end
    fprintf('-----------------------------------------------------------------------------\n')

end

function fprintCF(CF,CF_Comp,CF_Vars,CF_Freq,pMetrics,folder);
    fprintf('Cost function: %6.4f  (%s)\n',CF, folder);

    %% Component print
    %CompNames=pMetrics.uComponents;
    %for iC=1:length(CompNames)
    %    fprintf('               %6.3f (%5.1f%%) - %s\n',CF_Comp(iC),CF_Comp(iC)/CF*100,CompNames{iC});
    %end
    %% Var print
    % for iV=1:length(VarNames)
    %     fprintf(' CF:%10f - Val: %10.3e, Ref:%10.3e,  Sig:%.4e, Fact:%f, - %s %s\n',CF_Vars(iV),Metrics.Values(iV), pMetrics.xRef(iV),pMetrics.sigma(iV), pMetrics.VarsWeights(iV),pMetrics.Vars{iV,2},VarNames{iV});
    % end

    %% Frequency print
    %
    IComp       = find(cellfun(@(x)~isempty(strfind(x,'FR')),pMetrics.Vars(:,2)));
    iAEP        = find(ismember(pMetrics.Vars(:,1),'AEP'))                 ;
    IContraints = find(cellfun(@(x)~isempty(x), pMetrics.Vars(:,4)))       ;
    freqs =  cell2mat(pMetrics.FreqVars(:,2)); 

    FreqNames=cellfun(@(x)sprintf('%.2fHz',x),pMetrics.FreqVars(:,2),'UniformOutput',false);
    FreqNames{end+1}='ULS';
    FreqNames{end+1}='Sum';
    CompNames= pMetrics.Vars(IComp,5);
    CompNames{end+1}='Sum';

    fprintf('\nAbsolute contributions to the cost function per frequency\n\n')
    %%
    MAbs = CF_Freq.MAbs(IComp,:);
    MAbs2=nan(size(MAbs,1)+1,size(MAbs,2)+1);
    MAbs2(1:end-1,1:end-1)=MAbs;
    for i=1:size(MAbs,1)
        MAbs2(i,end)=fnansum(MAbs(i,:));
    end
    for j=1:size(MAbs2,2)
        MAbs2(end,j)=fnansum(MAbs2(:,j));
    end
    %  MAbs2(:,end+1) = fnansum(MAbs');
    %  MAbs2(end+1,:) = fnansum(MAbs);
    sTab=fTablePrint(MAbs2,FreqNames,CompNames,'','%7.3f','\t');
    fprintf('%s\n',sTab{:});

    FreqNames=cellfun(@(x)sprintf('%.2fHz',x),pMetrics.FreqVars(:,2),'UniformOutput',false);
    FreqNames{end+1}='ULS';
    CompNames= pMetrics.Vars(IComp,5);
    fprintf('\nRelative contributions to the cost function per frequency\n\n')
    MRel = CF_Freq.MRi(IComp,:);
    sTab=fTablePrint(MRel,FreqNames,CompNames,'','%7.2f','');
    fprintf('%s\n',sTab{:});

    fprintf('\n');

end
