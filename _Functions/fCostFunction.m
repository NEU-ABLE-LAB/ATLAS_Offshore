function [CF, CF_Comp, CF_Vars, CF_Freq] = fCostFunction(x,xRef,p)
% Compute cost function 
% 
% INPUTS: 
%   x   : Values of each metrics
%   xRef: Values of each metrics for the reference case
%   p   : Metrics parameters as returned by fMetricsVars
% OUTPUTS:
%   CF        : cost function (scalar)
%   CF_Comp   : cost function contribution per turbine component
%   CF_Vars   : cost function contribution per metrics variables
% 

PENALTY = 1000;

% Variables for FFT metrics
cFreqAll =  p.FreqVars(:,1); % cell with names of frequencies (e.g. 1P, Blade Flap)
n        = [ cell2mat(p.FreqVars(:,3)); 1] ; % NOTE: last exponent is 1 for ULS

% --- Contribution of each metrics variable 
% Baseline equation : CF_Vars = p.VarsWeights(:) .* x(:)./xRef(:);
nVars      = size(p.Vars,1)      ;
CF_Vars    = nan(1,nVars)        ;

CF_Freq.Ri  =cell(nVars,1);
CF_Freq.Rin =cell(nVars,1);
CF_Freq.RinR=cell(nVars,1);
CF_Freq.Ki  =cell(nVars,1);

for i = 1:nVars
    if length(x{i})>1 % frequencies
        cFreqRelevant = p.Vars{i,6};    % cell of frequencies of interest for the current variable
        CF_Freq.Ri {i} = zeros(1,length(cFreqRelevant)+1); % NOTE: +1 for ULS
        CF_Freq.Rin{i} = zeros(1,length(cFreqRelevant)+1); % NOTE: +1 for ULS
        nSum=0;
        CF_Freq.Ki{i}=nan(1,length(cFreqRelevant)+1);
        for kk = 1:length(cFreqRelevant)
            k = find(ismember(cFreqAll,cFreqRelevant{kk})); 
            if isempty(k)
                error('Wrong frequency name %s',cFreqRelevant{kk}); 
            end
            CF_Freq.Ki{i}(kk) = k;
            CF_Freq.Ri {i}(kk) =  ( x{i}(k)/xRef{i}(k) );
            CF_Freq.Rin{i}(kk) =  ( x{i}(k)/xRef{i}(k) ).*n(k); % Ratio of spectra amplitudes, to the power n
            nSum=nSum+n(k);
        end
        CF_Freq.Ki{i}(end) = length(cFreqAll)+1;
        %  Last is ULS
        pULS=0.25; 
        nULS=pULS/(1-pULS)*nSum; % scale such that ULS portion is pULS
        CF_Freq.Ri {i}(end) = ( x{i}(end)/xRef{i}(end) )  ; % For ULS 
        CF_Freq.Rin{i}(end) = ( x{i}(end)/xRef{i}(end) )*nULS; % For ULS 
        nSum=nSum+nULS;
        CF_Freq.RinR{i} =CF_Freq.Rin{i}/nSum;

        CF_Vars(i) = p.VarsWeights(i) * sum(CF_Freq.Rin{i})/nSum;
    else % regular metric 
        %CF_Vars(i) = p.VarsWeights(i) * x{i}./xRef{i};
    end
end


% Constraints
Constraints = p.Vars(:,4);
IContraints = find(cellfun(@(x)~isempty(x), Constraints));
CF_Constraints = 0;
for ic = 1:length(IContraints)
	iic = IContraints(ic);
	if x{iic}>Constraints{iic}
		fprintf('!!! Constraint exceeded for %s (%f > %f) \n',p.Vars{iic,1},x{iic},Constraints{iic});
		CF_Vars(iic) = PENALTY;
        CF_Constraints = CF_Constraints + PENALTY;
	else
		CF_Vars(iic) = 0;
	end
end

% --- Cost function
iAEP = find(ismember(p.Vars(:,1),'AEP'));
IVars = setdiff(1:size(p.Vars,1), iAEP);
AEP_Scale = x{iAEP}/xRef{iAEP}; 

% Penelize simulations that result in negative energy generation
if AEP_Scale < 0
    CF_Constraints = CF_Constraints + PENALTY;
end

CF_Vars(iAEP) =  1/AEP_Scale ; % Inverse here so all all factors whould be minimized

if CF_Constraints>0
    CF = CF_Constraints;
else
    CF = sum(CF_Vars(IVars)) * CF_Vars(iAEP);
end


% --- Contribution by component (for info)
Components = p.Vars(:,5);
CF_Comp = nan(1,p.nComp);
for iC = 1:p.nComp
    I = ismember(Components,p.uComponents{iC});
	CF_Comp(iC) = sum(CF_Vars(I));
end


% --- Contribution by frequencies (for info)
% We put eerything in a matrix of the same size for easy tabulated display
CF_Freq.MRi  = nan(nVars,length(cFreqAll)+1);
CF_Freq.MRin = nan(nVars,length(cFreqAll)+1);
CF_Freq.MRinR= nan(nVars,length(cFreqAll)+1);
CF_Freq.MAbs = nan(nVars,length(cFreqAll)+1);
for i = 1:nVars
    if length(x{i})>1 % frequencies
        cFreqRelevant = p.Vars{i,6};    % cell of frequencies of interest for the current variable
        Ki = CF_Freq.Ki{i};
        CF_Freq.MRi       (i,Ki) = CF_Freq.Ri {i};
        CF_Freq.MRin      (i,Ki) = CF_Freq.Rin {i};
        CF_Freq.MRinR     (i,Ki) = CF_Freq.RinR{i};
        CF_Freq.MAbs      (i,Ki) = CF_Freq.RinR{i}*p.VarsWeights(i)/AEP_Scale;
        CF_Freq.MAbsNoAEP (i,Ki) = CF_Freq.RinR{i}*p.VarsWeights(i);
        %CF_Freq.Rin{i}
    else % regular metric 
        %CF_Vars(i) = p.VarsWeights(i) * x{i}./xRef{i};
    end
end


end
