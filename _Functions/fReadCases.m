function Cases=fReadCases(filename,VRated)

% --- Optional arguments
if ~exist('VRated','var'); VRated=11.4; end;



Cases=struct();

% --- Reading column names
if ~exist(filename,'file')
    error('Case file %s not found.',filename)
end

fid= fopen(filename,'r');
data = textscan(fid,'%s',1,'delimiter', '\n');
fclose(fid); 
ColNames = strsplit(data{1}{1}); % DLC	WSAbove	YawErr	WindSeed	WaveSeed	B1Pitch	WindType	DirtyAero	Tsim	CaseName

% --- Reading full table
nNumCols = 9; % hard coded for now
% Cases.Tab=dlmread(filename,'',1,0);
fid = fopen(filename);
M = textscan(fid, [repmat('%f ',1,nNumCols) '%s'],'HeaderLines',1);
fclose(fid);

Cases.Tab=cell2mat(M(:,1:nNumCols));

Cases.DLC    = Cases.Tab(:, getCol('DLC'));
Cases.WS     = Cases.Tab(:, getCol('WSAbove')) + VRated;
Cases.Yaw    = Cases.Tab(:, getCol('YawErr'));
Cases.WiSeed = Cases.Tab(:, getCol('WindSeed'));
Cases.WaSeed = Cases.Tab(:, getCol('WaveSeed'));
Cases.bPitch = Cases.Tab(:, getCol('B1Pitch'));
Cases.iGust  = Cases.Tab(:, getCol('WindType'));
Cases.bDirty = Cases.Tab(:, getCol('Dirty'));
Cases.tSim   = Cases.Tab(:, getCol('Tsim')); 

% --- Reading filenames (assumed to be last column)
Cases.Names = M(:,end);
Cases.Names = Cases.Names{1};
for i=1:length(Cases.Names)
    Cases.Names{i}=strrep(Cases.Names{i},'''','');
end
% fid   = fopen(filename);
% Cases.Names = textscan(fid, [repmat('%*f\t',1,size(Cases.Tab,2)-1) '%s'],'HeaderLines',1);
% Cases.Names = Cases.Names{1};
% fclose(fid);

% 
function i=getCol(c)
    i= find(cellfun(@(x)~isempty(x),strfind(ColNames,c)),1);
    if isempty(i); error('Column %s not found in file %s',c,filename); end
end

end
