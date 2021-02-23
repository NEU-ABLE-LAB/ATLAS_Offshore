function fBuildPlots(CF, BL, pMetricsBC, plotTag, ctrl_names)
nouts = size(CF,2);            %number of outputs, should equal the number of controlers
nnames = size(ctrl_names,2);

%% build the folders array that the ATLAS plotting function is expecting
folders = cell(1 + nouts, 2);
folders{1,1} = '';
folders{1,2} = 'Baseline Results';
for j = 1:nouts                       
    %for each controler either name it the controler name or call it  'controler #'
    if j <= nnames
        folders{j+1,2} = cell2mat(ctrl_names(j));
    else
        folders{j+1,2} = sprintf('Controler %i',j);
    end
    folders{j+1,1} = '';
end

%% build the inputs the way the ATLAS plotting function is expecting 
%prealocate and add baseline results         
pCF = [BL.CF zeros(1,nouts)];
pCF_Comp = [BL.CF_Comp; zeros(nouts,6)];
pCF_Vars = [BL.CF_Vars; zeros(nouts,12)];
pCF_Freq = cell(1,1+nouts);    
pCF_Freq{1} = BL.CF_Freq;

%loop on output results
for cN = 1 : nouts
    pCF(cN+1) = CF(cN).CF;
    pCF_Comp(cN+1,:) = CF(cN).CF_Comp;
    pCF_Vars(cN+1,:) = CF(cN).CF_Vars;    
    pCF_Freq{cN+1} = CF(cN).CF_Freq; 
end

%% look at plotTag, determine how to plot
switch plotTag.Combine
    case 'yes'
        % everything is set to plot already 
        fCostFunctionPlotTag(pCF, pCF_Comp, pCF_Vars, pCF_Freq, pMetricsBC, folders, plotTag) 
    otherwise
        %plot each controler individualy
        for cN = 1 :nouts
            %overwrite folders, its easier than trying to pul
            folders2 = {'','Baseline Results';'',folders{1+cN,2}};   %overwrite folders, its easier
            
            % build plotting function inputs
            SpCF = [pCF(1) pCF(cN)];
            SpCF_Comp = [pCF_Comp(1,:); pCF_Comp(cN,:)];
            SpCF_Vars = [pCF_Vars(1,:); pCF_Vars(cN,:)];
            SpCF_Freq = {pCF_Freq{1}, pCF_Freq{cN}};
            
            %atlas plot function
            fCostFunctionPlotTag(SpCF, SpCF_Comp, SpCF_Vars, SpCF_Freq, pMetricsBC, folders2, plotTag)
        end
end
end