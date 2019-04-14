function M = fEvaluateMetrics(R, p)
%
% Evaluate the values of the metrics variables, from the stats of the files
% The metrics values for each variable are stored in the variable M.Values.
% 
% INPUTS: 
%   R: structure returned by fComputeOutStats, contains statistics for each signal and files
%   p: structure returned by fMetricVars, contains infor about how to compute the metrics
%
% OUTPUTS: 
%   M: a structure containing the metrics values, and the values that were used to compute it

nVars    = size(p.Vars,1)    ;
nCases   = length(R.OutFiles);
nRefFreq = size(p.FreqVars,1);
% --- Allocations - The only important one is `Values`, the rest is for plotting
Values      = cell(1,nVars)                   ;
IMain       = nan(1,nVars)                    ;
VarValues   = nan(nCases,nVars)               ;
PlotValues  = nan(nCases,nVars)               ;
SpecA       = NaN(nRefFreq,nCases,nVars)      ;
SpecAMax    = NaN(nRefFreq,nVars)             ;
Freq        = R.Freq                          ;
Spec        = NaN(nCases,nVars,length(R.Freq));
% freqs = cell2mat(p.FreqVars(:,2))  ;    % frequencies of interest
% n     = [ cell2mat(p.FreqVars(:,3)); 1]; % NOTE: last exponent is 1 for ULS
% SpecAMaxExp = NaN(nRefFreq+1,nVars)           ; % NOTE: +1 for ULS

% --- Computing value of each variable
for iVar = 1:nVars
    id = fGetChannelID(R.ChanName, p.Vars{iVar,3});
    
    if length(id)>1
        id = id(1); % duplicate channel name
        fprintf('Duplicate channel name: %s %s\n',p.Vars{iVar,3},R.ChanName{id})
    end

    Kind = p.Vars{iVar, 2};
    if     isequal(Kind, 'CONSTR') % NOTE: same as ULS-ULS
        VarValues(:,iVar) = R.Max(:,id);
        [Values{iVar}, IMain(iVar)] = max(VarValues(:,iVar));
        PlotValues(:,iVar)          = VarValues(:,iVar)     ;
        
    elseif strfind(Kind,'FRQ')==1
        % Spectral amplitudes at frequencies of interest
        for iFreq=1:nRefFreq
            for iCase=1:nCases
                Spec(iCase,iVar,:) = R.Spec{iCase,id}; % storing full spectrum for plotting
                SpecA(iFreq,iCase,iVar)=interp1(R.Freq,R.Spec{iCase,id},p.FreqVars{iFreq,2});
            end
            % Taking max amplitude over all cases
            SpecAMax   (iFreq,iVar) = max(squeeze(SpecA(iFreq,:,iVar)));
            %SpecAMaxExp(iFreq,iVar) =  SpecAMax(iFreq,iVar)^n(iFreq);
        end
        %  Last component is "ULS"
        %SpecAMaxExp(nRefFreq+1,iVar) =  max(R.Max(:,id))^1;
        %Values(iVar) = prod(SpecAMaxExp(:,iVar));
        Values{iVar} = [SpecAMax(:,iVar)' max(R.Max(:,id))]; % NOTE: adding ULS value at the end

    elseif strfind(Kind,'ULS-')==1
        if     isequal(Kind, 'ULS-ULS'); VarValues(:,iVar) = R.Max(:,id);
        elseif isequal(Kind, 'ULS-FLS'); VarValues(:,iVar) = R.Std(:,id);
        else error('Unsupported subkind %s',Kind); end
        [Values{iVar}, IMain(iVar)] = max(VarValues(:,iVar));
        PlotValues(:,iVar)          = VarValues(:,iVar)     ;
    elseif strfind(Kind,'MEAN')==1 % FLS has been removed now
        if     isequal(Kind, 'MEAN-Mean')
            Val = R.Mean(:,id);
        elseif isequal(Kind, 'MEAN-Trvl')
            Val = R.Trvl(:,id);
        else
            error('Unsupported subkind %s',Kind);
        end
        PlotValues(:,iVar) = Val;
        VarValues(:,iVar)  = Val; % NOTE: no probability
        [~, IMain(iVar)]   = max (VarValues(:,iVar));
        Values{iVar}       = mean(VarValues(:,iVar));
    else
        error('Unsupported kind %s',Kind)
    end
end

% 
M.Values     = Values    ; % Metric Values
M.VarValues  = VarValues ; % Values used to compute the metrics 
% Values below are for plotting only
M.PlotValues = PlotValues;
M.IMain      = IMain     ;
M.SpecA      = SpecA      ;
M.SpecAMax   = SpecAMax   ;
% M.SpecAMaxExp = SpecAMaxExp;
M.Spec       = Spec   ;
M.Freq       = Freq   ;

end
