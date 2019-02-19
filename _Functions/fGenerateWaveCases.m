function fGenerateWaveCases(case_file,ref_driver_filename, ref_hydro_filename, nssfile, HydroDyn, outdir, bForceGeneration, bCleanUp)
% %% Parameters
% case_file           = '_inputs/Cases.csv'                    ;
% ref_driver_filename = '_inputs/Template_HydroDyn_Drv_Inp.dvr';
% ref_hydro_filename  = '_inputs/Template_HydroDyn_Drv_Inp.dat';
% nssfile             = '_inputs/NSS.csv'                      ;
% HydroDyn            = 'HydroDynDriver_x64.exe'               ;
% outdir              = 'Waves\'                               ;
% bCleanUp            = logical(1)                             ;
% bForceGeneration    = logical(1)                             ;
% 
bOpenFAST = 1;
dtOut = 0.25 ;

%% Derived parameters
if ~exist(outdir,'dir'); mkdir(outdir); end;

%% Reading cases 
Cases    = fReadCases(case_file)  ;
% Selecting unique wave and seed combination, where seed is not 0
WS_Seed = [Cases.WS Cases.WaSeed];
[WS_Seed,I] = unique(WS_Seed(Cases.WaSeed>0,:),'rows');

%% Reading wave condition
NSS=dlmread(nssfile,'',1,0);
vWS = NSS(:,1);
vHs = NSS(:,3);
vTp = (NSS(:,4) + NSS(:,5))/2;

basename    = 'wave'                  ;


%% Creating input files for NSS
for i = 1:size(WS_Seed,1);
    WS    = WS_Seed(i,1)         ;
    iSeed = WS_Seed(i,2)         ;
    Tsim  = max( Cases.tSim( (Cases.WS== WS) & (Cases.WaSeed ==iSeed) ) );
    Hs    = interp1(vWS, vHs, WS);
    Tp    = interp1(vWS, vTp, WS);
    base  = sprintf('%s_ws%02.0f_r%d',basename,round(WS),iSeed);
    input_filename  =  sprintf('%s%s.dvr',outdir,base);
    output_filename =  strrep(input_filename,'.dvr','.Elev');
    if exist(output_filename,'file') && ~bForceGeneration; 
        fprintf('>>> File exist %s. Skipping (use bForce or delete this file)\n',output_filename);
    else
        fprintf('-----------------------------------------------------------------------------\n');
        fprintf('>>> Generating %s - ws=%.1f - Hs = %.2f - Tp = %.1f ...\n',output_filename,WS,Hs,Tp);
        fprintf('-----------------------------------------------------------------------------\n');
        fGenerateWave(Hs,Tp,iSeed,Tsim,dtOut,input_filename,ref_driver_filename,ref_hydro_filename, HydroDyn, bOpenFAST, bCleanUp);
    end
end

