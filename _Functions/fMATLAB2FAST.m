function fMATLAB2FAST(p, fileout)

fid = fopen(fileout,'w');
fprintf(fid,'%s\r\n',p.Lines{:});
fclose(fid);

    
    

