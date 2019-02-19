function fGenerateTurb(ref_filename, input_filename, turbsim, bCleanUp, WS, iSeed )
% Generate a turbulence file using TurbSim, for a given Wind Speed and Seed

% Reading template
inp_ref = fFAST2MATLAB(ref_filename);
% Creating input file for TurbSim
inp = inp_ref;
inp = fChangeVal(inp, 'RandSeed1', 10000+iSeed);
inp = fChangeVal(inp, 'URef'     , WS);
fMATLAB2FAST(inp, input_filename) ;

output_filename =  strrep(input_filename,'.dat','.bts');

% System call to generate file
sCmd = sprintf('%s %s',turbsim, input_filename);
iStat = system(sCmd);
if ~exist(output_filename,'file')
    error('Turb file not properly created')
else
    if bCleanUp
        % Clean up
        warning off
        delete(strrep(output_filename,'.bts','.sum'));
        delete(strrep(output_filename,'.bts','.ech'));
        delete(input_filename);
        warning off
    end
end
