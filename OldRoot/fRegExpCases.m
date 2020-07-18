%% Cases=fRegExpCases returns properties of the simulation case
% Mimics fReadCases, but interprets case info from file name
function Cases=fRegExpCases(filenames,VRated)

% --- Optional arguments
if ~exist('VRated','var')
    VRated = 11.4;
end

% Filename can be char array, cell array of chars, or string arraw
if ischar(filenames) 
    % Input is a character array
    nCases = 1;
    filenames = {filenames};
else 
    % Input is a string array or cell array of charater arrays 
    nCases = length(filenames);
end

% Cases = struct('DLC',[],'WSAbove',[],'YawErr',[],'WindSeed',[],'WaveSeed',[],'B1Pitch',[],'WindType',[],'DirtyAero',[],'Tsim',[],'CaseName',[]);
Cases = struct();

ColNames = {'DLC' 'WSAbove' 'YawErre' 'WindSeede' 'WaveSeede' ...
    'B1Pitche' 'WindTypee' 'DirtyAeroe' 'Tsime' 'CaseName'};
nNumCols = 9; % hard coded for now

%% (Tab) All the data in tabular form
Cases.Tab = zeros(nCases, nNumCols);

for caseN = 1:nCases
    %% (DLC) Design load case
    tokens = regexp(filenames{caseN}, 'DLC(\d+)_','tokens');
    DLC = str2double(tokens{1}{1});
    
    Cases.DLC(caseN) = DLC;
    Cases.Tab(caseN, getCol('DLC')) = DLC;

    %% (WS) Wind speed
    tokens = regexp(filenames{caseN}, '_ws(\d+)_','tokens');
    WSAbove = str2double(tokens{1}{1});
    ws = WSAbove + VRated;
    
    Cases.ws(caseN) = ws;
    Cases.Tab(caseN, getCol('WSAbove')) = ws;

    %% (Yaw) Yaw error
    if contains(filenames{caseN}, '_yeNEG_')
        YawErr = -10;
    elseif contains(filenames{caseN}, '_ye000_')
        YawErr = 0;
    else
        error('Unknown yaw error setting')
    end
    
    Cases.Yaw(caseN) = YawErr;
    Cases.Tab(caseN, getCol('YawErr')) = YawErr;

    %% (WiSeed) Wind seed
    tokens = regexp(filenames{caseN}, '_s(\d+)_','tokens');
    WiSeed = str2double(tokens{1}{1});
    
    Cases.WiSeed(caseN) = WiSeed;
    Cases.Tab(caseN, getCol('WiSeed')) = WiSeed;

    %% (WaSeed) Wave seed
    tokens = regexp(filenames{caseN}, '_r(\d+)','tokens');
    WaSeed = str2double(tokens{1}{1});
    
    Cases.WaSeed(caseN) = WaSeed;
    Cases.Tab(caseN, getCol('WaSeed')) = WaSeed;

    %% (bPitch) Blade pitch
    bPitch = 0;
    if contains(filenames{caseN}, '_PIT')
        bPitch = 1;
    end

    Cases.bPitch(caseN) = bPitch;
    Cases.Tab(caseN, getCol('bPitch')) = bPitch;
        
    %% (iGust) Wind type
    %   * (ECD) Extreme Coherent gust with Direction Change
    %   * (EWS) Extreme Wind Shear
    %   * (EOG) Extreme Operating Gust
    %   * (STP) Step of wind speed
    
    iGust = 0;
    if contains(filenames{caseN}, '_ECD')
        iGust = 1;
    elseif contains(filenames{caseN}, '_EOG')
        iGust = 2;
    elseif contains(filenames{caseN}, '_EWS')
        iGust = 3;
    elseif contains(filenames{caseN}, '_STP')
        iGust = 4;
    end
    
    Cases.iGust(caseN) = iGust;
    Cases.Tab(caseN, getCol('iGust')) = iGust;

    %% (bDirty) Blade is clean or dirty
    bDirty = 0;
    if contains(filenames{caseN}, '_DRT')
        bDirty = 1;
    end
    
    Cases.bDirty(caseN) = bDirty;
    Cases.Tab(caseN, getCol('bDirty')) = bDirty;

    %% (tSim) Simulation length (s)
    % The file names don't contain the simulation length.
    % Instead, do a lookup.
    if contains(filenames{caseN}, 'DLC120_ws13_yeNEG_s2_r3_PIT') || ...
            contains(filenames{caseN}, 'DLC120_ws13_ye000_s1_r1') || ...
            contains(filenames{caseN}, 'DLC120_ws19_yeNEG_s3_r2') || ...
            contains(filenames{caseN}, 'DLC120_ws19_ye000_s2_r1_PIT') || ...
            contains(filenames{caseN}, 'DLC120_ws23_ye000_s3_r3') || ...
            contains(filenames{caseN}, 'DLC121_ws13_ye000_s1_r1_DRT') || ...
            contains(filenames{caseN}, 'DLC121_ws19_ye000_s2_r2_DRT') || ...
            contains(filenames{caseN}, 'DLC121_ws23_ye000_s3_r3_DRT')
        tSim = 600;
    elseif contains(filenames{caseN}, 'DLC140_ws13_ye000_s0_r1_ECD') || ...
            contains(filenames{caseN}, 'DLC150_ws13_ye000_s0_r1_EWS') || ...
            contains(filenames{caseN}, 'DLC230_ws13_ye000_s0_r1_EOG')
        tSim = 200;
    elseif contains(filenames{caseN}, 'DLC122_ws15_ye000_s0_r1_STP')
        tSim = 1200;
    else
        error('Unknown Tsim')
    end
    
    Cases.tSim(caseN) = tSim;
    Cases.Tab(caseN, getCol('tSim')) = tSim;
    
    %% (Names) File names
    Cases.Names{caseN} = filenames{caseN};

end

function i=getCol(c)
    i= find(cellfun(@(x)~isempty(x),strfind(ColNames,c)),1);
end
end