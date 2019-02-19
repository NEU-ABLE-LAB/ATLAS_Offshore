function p=fMetricVars(Cases,Challenge);
%  INPUTS:
%     Cases: as returned by fReadCases 
%     Challenge: 'onshore' or 'offshore'

% 
p.tStart=50; % neglecting transients in the first tStart seconds
p.FFT_WinLen = 4096;% Window Length for Spectra averaging. Smoother with lower window sizes

% --- Channels to be added to output files
p.AdditionalChannels={
'TwrClearance', '-transpose(min(transpose([{TwrClrnc1} {TwrClrnc2} {TwrClrnc3}])))';
'RootMnormc1', 'sqrt({RootMxc1}.^2  + {RootMyc1}.^2)';
'TwrBsMnormt', 'sqrt({TwrBsMxt}.^2  + {TwrBsMyt}.^2)';
'NcIMUTAs'   , 'sqrt({NcIMUTAxs}.^2 + {NcIMUTAys}.^2 + {NcIMUTAzs}.^2)';
'LSSGagnorma', 'sqrt({LSSGagMya}.^2 + {LSSGagMza}.^2)';
'BldPitch1P' , 'fDiffSmoothStart({BldPitch1},10)/dt';
'BldPitch2P' , 'fDiffSmoothStart({BldPitch2},10)/dt';
'BldPitch3P' , 'fDiffSmoothStart({BldPitch3},10)/dt';
};

%% --- Variables, Kind, Channel, Constraint, Component, Frequencies
p.Vars={
% Blades
% 'Bld Root Mn'       , 'FRQ-ULS'   , 'RootMnormc1' , [  ] , 'Rotor'  , {''};
% 'Bld Root Mx'       , 'FRQ-FLS'   , 'RootMxc1'    , [  ] , 'Rotor'  , {'1P','2P','Blade Edge collective'};
'Bld Root My'       , 'FRQ-FLS'   , 'RootMyc1'    , [  ] , 'Rotor'  , {'1P','2P','Blade Edge collective'};
'Bld Root Mz'       , 'FRQ-FLS'   , 'RootMzc1'    , [  ] , 'Hub'    , {'1P','2P','Blade Edge collective'};
% 'Bld Root Mz max' , 'FRQ-ULS'   , 'RootMzc1'    , [  ] , 'Hub'    , {''}; % <<
% 'Bld1 Pitch Trvl' , 'MEAN-Trvl' , 'BldPitch1'   , [  ] , 'Hub'    , {''};
% 'Bld2 Pitch Trvl' , 'MEAN-Trvl' , 'BldPitch2'   , [  ] , 'Hub'    , {''};
% 'Bld3 Pitch Trvl' , 'MEAN-Trvl' , 'BldPitch3'   , [  ] , 'Hub'    , {''};
% Drive train
% 'LSS Mn'          , 'FRQ-ULS'   , 'LSSGagnorma' , [  ] , 'Nacelle', {''};
% 'LSS My'          , 'FRQ-FLS'   , 'LSSGagMya'   , [  ] , 'Nacelle', {''};
% 'LSS Mz'          , 'FRQ-FLS'   , 'LSSGagMza'   , [  ] , 'Nacelle', {''};
'LSS Torque'        , 'FRQ-FLS'   , 'RotTorq'     , [  ] , 'Nacelle', {'3P','Drivetrain torsion'};
% 'LSS Torque max'  , 'FRQ-ULS'   , 'RotTorq'     , [  ] , 'Nacelle', {''}; % <<
% 'Rot Speed'       , 'FRQ-FLS'   , 'RotSpeed'    , [  ] , 'Nacelle', {''};
% Tower
% 'Twr Bot Mn'        , 'FRQ-ULS'   , 'TwrBsMnormt' , [  ] , 'Tower'  , {''};
% 'Twr Bot Mx'        , 'FRQ-FLS'   , 'TwrBsMxt'    , [  ] , 'Tower'  , {''};
'Twr Bot My'        , 'FRQ-FLS'   , 'TwrBsMyt'    , [  ] , 'Tower'  , {'Tower Fore-Aft','3P','Blade Edge regressive','Blade Edge progressive'};
% 'Twr Bot Mz'      , 'FRQ-FLS'   , 'TwrBsMzt'    , [  ] , 'Tower'  , {''};
% 'Twr Bot Mz max'  , 'FRQ-ULS'   , 'TwrBsMzt'    , [  ] , 'Tower'  , {''}; % <<
% AEP
'AEP'             ,'MEAN-Mean','GenPwr'      ,[  ],'AEP'   ,[] ;
% Constraints
'Bld1 Pitch Speed' , 'CONSTR' , 'BldPitch1P'   , 10   , '' , []      ; % <<< Constraints 10deg/s
'Bld2 Pitch Speed' , 'CONSTR' , 'BldPitch2P'   , 10   , '' , []      ; % <<< Constraints 10deg/s
'Bld3 Pitch Speed' , 'CONSTR' , 'BldPitch3P'   , 10   , '' , []      ; % <<< Constraints 10deg/s
'Twr Clear.'       , 'CONSTR' , 'TwrClearance' , -4   , '' , []      ; % <<< Constraints 4m        = 30 % undefl clearance = 0.3*(63*sind(2.5+5)+5)
'Twr Top Acc'      , 'CONSTR' , 'NcIMUTAs'     , 3.3  , '' , []      ; % <<< Constraints g/3 m/s^2
'Rot Speed MAX'    , 'CONSTR' , 'RotSpeed'     , 15.73, '' , []      ; % <<< Constraints 
};
if isequal(lower(Challenge), 'offshore')
    % --- Adding more metrics for the offshore case
    OffshoreVars={
        % Platform
        'Platform Pitch'     , 'FRQ-FLS'  , 'PtfmPitch' , [] ,'Platform' , {'Platform Pitch','Tower Fore-Aft'};
%         'Platform Roll'      , 'FRQ-FLS'  , 'PtfmRoll'  , [] ,'Platform' , {};
%         'Platform Yaw'       , 'FRQ-FLS'  , 'PtfmYaw'   , [] ,'Platform' , {};
        % 'Platform Pitch Rate' , 'ULS'      , 'PtfmRVyt'    ;
    };
    p.Vars=[p.Vars; OffshoreVars];
end


%% --- Frequencies of interest (assumed constant)
% FreqVars is nx3 with columns: Name, Frequency, "n" exponent
f_rated=12.1/60; % [Hz]
if isequal(lower(Challenge), 'offshore')
    p.FreqVars={
%       'Platform Surge/Sway'     , 0.025     , 1.0; 
      'Platform Pitch'          , 0.036     , 0.375; 
%       'Platform Yaw'            , 0.105     , 0.710; 
      '1P'                      , f_rated   , 1.000; 
      '2P'                      , 2*f_rated , 1.000; 
%       'Tower Side-Side'         , 0.495     , 1.000; 
      'Tower Fore-Aft'          , 0.502     , 1.000; 
%       'Blade Flap regressive'   , 0.569     , 1.000; 
%       'Blade Flap collective'   , 0.752     , 1.000; 
      '3P'                      , 3*f_rated , 0.848; % 0.6
%       '4P'                      , 4*f_rated , 0.800; % 0.8
      'Blade Edge regressive'   , 0.891     , 0.709; 
%       'Blade Flap progressive'  , 0.913     , 0.687; 
%       '5P'                      , 5*f_rated , 0.600; % 1.0
      'Blade Edge collective'   , 1.100     , 0.500; 
%       '6P'                      , 6*f_rated , 0.450; % 1.2
      'Blade Edge progressive'  , 1.298     , 0.402; 
      'Drivetrain torsion'      , 1.705     , 0.200; 
    };
elseif isequal(lower(Challenge), 'onshore')
    p.FreqVars={
      '1P'                     , f_rated   , 1.000;  %0.2
%       'Tower Side-Side'        , 0.375     , 1.000; 
      'Tower Fore-Aft'         , 0.382     , 1.000; 
      '2P'                     , 2*f_rated , 1.000; % 0.4
%       'Blade Flap regressive'  , 0.573     , 1.000; 
      '3P'                     , 3*f_rated , 1.000; % 0.6
%       'Blade Flap collective'  , 0.756     , 0.844; 
%       '4P'                     , 4*f_rated , 0.800; % 0.8
      'Blade Edge regressive'  , 0.887     , 0.713; 
%       '5P'                     , 5*f_rated , 0.600; % 1.0
%       'Blade Flap progressive' , 0.916     , 0.684; 
      'Blade Edge collective'  , 1.100     , 0.500; 
%       '6P'                     , 6*f_rated , 0.450;  % 1.2
      'Blade Edge progressive' , 1.295     , 0.402; 
      'Drivetrain torsion'     , 1.697     , 0.200; 
      }                                    ; 
else
    error('Challenge is either offshore or onshore')
end

% --- Establishing n as function of freq:
% freqs=cell2mat(p.FreqVars(:,2));
% p.FreqVars(:,3)= num2cell(freqs/min(freqs));
% p.FreqVars(:,3)= num2cell(min(freqs)./freqs);
% p.FreqVars(:,3)= num2cell(1+1*(freqs-min(freqs))/(max(freqs)-min(freqs)));
%



%% --- Contribution for each component
if isequal(lower(Challenge), 'offshore')
    %              Component    , Total 
    p.CompContrib={'AEP'        , 1.0  ;
                   'Rotor'      , 0.11 ;
                   'Hub'        , 0.02 ;
                   'Nacelle'    , 0.11 ;
                   'Tower'      , 0.11 ;
                   'Platform'   , 0.64 ;
                   }; 
else
    %              Component    , Total 
    p.CompContrib={'AEP'        , 1.0  ;
                   'Rotor'      , 0.31 ;
                   'Hub'        , 0.03 ; 
                   'Nacelle'    , 0.34 ;
                   'Tower'      , 0.32 ;
                   }; 
end

% --- Initialization of component 
Components =p.Vars(:,5);
%p.uComponents = unique(Components(cellfun( @(x)~isempty(x),Components)));
uComponentsFromVars = unique(Components(cellfun( @(x)~isempty(x),Components)));
p.uComponents = p.CompContrib(:,1);
if length(uComponentsFromVars)~=length(p.uComponents)
    error('Difference between pComponent and the ones used in vars')
end
p.nComp = length(p.uComponents);
p.VarsWeights = nan(1,size(p.Vars,1));
for iC = 1:p.nComp
    % check that the components we provided have some contrib info
    iic = find(ismember(p.CompContrib(:,1),p.uComponents{iC}));
    if isempty(iic); error('Unspecified component %s',p.uComponents{iC}); end
    % Findind variables that have that component
    I    = find(ismember(Components,p.uComponents{iC}));
    % Component weight
    C = p.CompContrib{iic,2};
    % Divide the component contribution equivalently between the metrics
    p.VarsWeights(I) = C/length(I); 
end

% --- Scaling Var contrib such that sum of weights is one
iAEP = find(ismember(p.Vars(:,1),'AEP'));
if isempty(iAEP) || length(iAEP)~=1; error('Vars need to contain AEP'); end
IVars = setdiff(1:size(p.Vars,1), iAEP);
ScaleFact = 1/fnansum(p.VarsWeights(IVars));
p.VarsWeights(IVars)= p.VarsWeights(IVars) *ScaleFact;

% --- "re-scaling" component contrib due to scaling above
p.CompWeights = nan(1,p.nComp);
for iC = 1:p.nComp
    iic = find(ismember(p.CompContrib(:,1),p.uComponents{iC}));
    I = find(ismember(Components,p.uComponents{iC}));
    p.CompWeights(iC) = sum(p.VarsWeights(I));
    if ~isequal(p.uComponents{iC},'AEP') && abs(p.CompWeights(iC)-p.CompContrib{iic,2}*ScaleFact)>1e-6
        fprintf('Comp %15s - %f  %f  %f\n',p.uComponents{iC},p.CompWeights(iC), p.CompContrib{iic,2}*ScaleFact , p.CompContrib{iic,2});
        error('Something is wrong in the scaling per components')
    end
end


end

