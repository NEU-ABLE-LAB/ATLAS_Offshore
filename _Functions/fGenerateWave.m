function wave_file_formated = fGenerateWave(Hs,Tp,iSeed,Tsim,dt,driver_filename,ref_driver_filename,ref_hydro_filename, HydroDyn, bOpenFAST, bCleanUp)
% Generate a wave using HydroDyn and format it to be compatible for OpenFast

nStep=round(Tsim/dt)+1;

%
[simdir,base,ext] = fileparts(driver_filename);
fullbase       = strrep(driver_filename,ext,'')    ;
hydro_filename = [fullbase '.dat'];

%% Reading templates for driver and dat file
drv_ref = fFAST2MATLAB(ref_driver_filename);
hdr_ref = fFAST2MATLAB(ref_hydro_filename);

% Changing driver file
drv = drv_ref;
drv = fChangeVal(drv, 'HDInputFile', ['"' hydro_filename '"']) ;
drv = fChangeVal(drv, 'OutRootName', ['"' fullbase '"']) ;
drv = fChangeVal(drv, 'NSteps'      , num2str(nStep)) ;
drv = fChangeVal(drv, 'TimeInterval', num2str(dt)) ;

% Changing data file
hdr = hdr_ref;
hdr = fChangeVal(hdr, 'WaveHs', num2str(Hs));
hdr = fChangeVal(hdr, 'WaveTp', num2str(Tp));
hdr = fChangeVal(hdr, 'WaveSeed(1)', num2str(1000+iSeed));

% Creating input files
fMATLAB2FAST(drv, driver_filename);
fMATLAB2FAST(hdr, hydro_filename);

% Command for batch file
sCmd = sprintf('%s %s',HydroDyn,driver_filename);

% --- Generating wave 
wave_file          = [fullbase '.HD.out'];
wave_file_formated = [fullbase '.Elev']  ;
iStat = system(sCmd);
if ~exist(wave_file,'file')
    error('Wave file not properly created')
else
    if bCleanUp
        warning off
        delete([fullbase '.Elev']);
        delete(driver_filename);
        delete(hydro_filename);
        warning off
    end
end

% --- Re-reading file
% fprintf('>>> Reading %s \n',wave_file)
fid=fopen(wave_file,'r');
nLines = nStep +5;
lines=cell(1,nLines);
for i=1:nLines
    tline = fgetl(fid);
    lines{1,i} = tline;
end
fclose(fid);


% -- Rewriting without end lines
fout = fopen(wave_file_formated,'w');
if bOpenFAST
    fprintf(fout,'%s\n',lines{4:end});
else
    fprintf(fout,'%s\n',lines{:});
end
fclose(fout);

% --- Deleting the original wave file
if bCleanUp
    delete(wave_file)
end
