function fCostFunctionPlotTag(CF, CF_Comp, CF_Vars, CF_Freq, pMetrics, folders, plotTag)

if exist('OCTAVE_VERSION', 'builtin') ~= 0; pkg load statistics; end;

%% Computing relative contributions to total CF
nFolders=size(folders,1);
CF_Comp_rel = CF_Comp(:,:)./repmat(pMetrics.CompWeights,nFolders,1);
CF_Vars_rel = CF_Vars(:,:)./repmat(pMetrics.VarsWeights,nFolders,1);
INC = find(cellfun(@(x)isempty(x), pMetrics.Vars(:,4)));

% --- Frequency
IComp       = find(cellfun(@(x)~isempty(strfind(x,'FR')),pMetrics.Vars(:,2)));
nFreqs = length(pMetrics.FreqVars(:,2))+1;
nComp = length(IComp);
FreqNames=cellfun(@(x)sprintf('%.2fHz',x),pMetrics.FreqVars(:,2),'UniformOutput',false);
FreqNames{end+1}='ULS';
Comp = pMetrics.Vars(IComp,5);



%% Relative contribution by frequency and component
if plotTag.Rel_FreqComp == 'plot'
    MRel_Combined = zeros(nFreqs, nFolders, nComp);
    for iFold = 1:nFolders
        MRel = CF_Freq{iFold}.MRi(IComp,:);
        MRel(isnan(MRel))=0;
        MRel_Combined(:,iFold, :) = MRel';
    end
    hf=figure('visible','off');
    ha = fTightSubplot(nComp+1,1,.03,.10,.1);
    for iComp=1:nComp
        %     subplot(nComp+1,1,iComp)
        axes(ha(iComp))
        bar(squeeze(MRel_Combined(:,:,iComp)))
        hold on
        plot([0 nFreqs+1],[1 1],'k--')
        ylabel(Comp{iComp})
        if iComp==1
            title('Relative contribution per frequency and component')
        end
        if iComp<nComp
            set(gca,'xticklabel',{[]})
        else
            set(gca,'xticklabel',FreqNames)
        end
    end
    % subplot(nComp+1,1,nComp+1)
    axes(ha(iComp+1))
    bar(zeros(nFolders,nFolders)); ylim([1,1.1]); axis off
    lh=legend(folders{:,2},'Location','South','Orientation','vertical');
    % P=get(gcf,'Position'); P(:,4)=P(:,4)*1.8;P(:,3)=P(:,3)*1.5;
    % set(gcf,'Position',P);
    set(hf,'visible','on')
end
%%
% fBarStackGroups(MRel_Combined, FreqNames);
% box on
% legend(RowNames,'Location','EastOutside')


%% Relative contribution per component
if plotTag.Rel_Comp == 'plot'
    figure
    bar([CF'  CF_Comp_rel(:,:)]');
    hold all
    plot([0,2+length(pMetrics.uComponents)],[1 1],'k--')
    set(gca,'xticklabel',{'Overall', '1/AEP',  pMetrics.uComponents{2:end}})
    legend(folders{:,2},'Location','EastOutside')
    xlim([0,2+length(pMetrics.uComponents)])
    % ylim([0.4,1.6])
    title('Relative contribution per component')
end

%% Absolute contribution by frequency and component
if plotTag.Abs_FreqComp == 'plot'
    MAbs_Combined = zeros(nFreqs, nFolders, nComp);
    for iFold = 1:nFolders
        MAbs = CF_Freq{iFold}.MAbs(IComp,:);
        MAbs(isnan(MAbs))=0;
        MAbs_Combined(:,iFold, :) = MAbs';
    end
    %
    hf=figure('visible','off');
    fBarStackGroups(MAbs_Combined, FreqNames);
    box on
    legend(Comp,'Location','EastOutside')
    title('Absolute contribution per frequency and component')
    ylabel('Absolute contribution to the cost function')
    % P=get(gcf,'Position'); P(:,3)=P(:,3)*1.5;
    % set(gcf,'Position',P);
    set(hf,'visible','on');
end

%% Absolute contribution per component
if plotTag.Abs_Comp == 'plot'
    figure
    if nFolders>1
        bar(CF_Comp(:,2:end),'stacked');
        hold all
        set(gca,'xticklabel',folders(:,2))
        legend({pMetrics.uComponents{2:end}},'Location','EastOutside')
    else
        bar(CF_Comp(:,2:end)); % TODO
    end
    title('Absolute contribution per component')
end


%% Relative contribution per variable
% figure
% bar([CF'  CF_Vars_rel(:,INC)]');
% hold all
% plot([0,2+length(INC)],[1 1],'k--')
% xtick = 1:length(INC)+1;
% xticklabel = {'Overall',pMetrics.Vars{INC,1}};
% set(gca,'xtick',xtick);
% set(gca,'xticklabel',xticklabel);
% legend(folders{:,2},'Location','South')
% title('Relative contribution per metric variable')
% frotatextick(45);
% xlim([0,2+length(INC)])
% % ylim([0.4,1.6])

