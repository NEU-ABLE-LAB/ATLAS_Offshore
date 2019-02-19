function fGenerateTurbCases(case_file,ref_turb_file,outdir, turbsim, bForceGeneration, bCleanUp)
% Generate turbulence files files based on a Template file and a Case file

%% Parameters
%case_file = '_inputs/Cases.csv'          ;
%turb_file = '_inputs/Template_TurbSim.dat';
%outdir    = 'Turb/'                       ; % with slash at the end
%driver    = 'TurbSim_x64.exe'             ;
%bForceGeneration = logical(1);
%bCleanUp  = logical(1); % Clean input/and intermediate file

%%
basename  = 'wind'                        ;

%% Reading cases 
Cases   = fReadCases(case_file)  ;
% Selecting unique wind and seed combination, where seed is not 0
WS_Seed = [Cases.WS Cases.WiSeed];
WS_Seed = unique(WS_Seed(Cases.WiSeed>0,:),'rows');


%% Creating input files

% Creating output folder 
if ~exist(outdir,'dir'); mkdir(outdir); end
% --- Loop on cases
for i = 1:size(WS_Seed,1);
    WS    = WS_Seed(i,1);
    iSeed = WS_Seed(i,2);
    base = sprintf('%s_ws%02.0f_s%d',basename,round(WS),iSeed);
    input_filename  =  sprintf('%s%s.dat',outdir,base);
    output_filename =  strrep(input_filename,'.dat','.bts');
    if exist(output_filename,'file') && ~bForceGeneration; 
        fprintf('>>> File exist %s. Skipping (use bForce or delete this file)\n',output_filename);
    else
        fprintf('-----------------------------------------------------------------------------\n');
        fprintf('>>> Generating %s ...\n',output_filename);
        fprintf('-----------------------------------------------------------------------------\n');
        fGenerateTurb(ref_turb_file, input_filename, turbsim, bCleanUp, WS, iSeed )
    end
end
