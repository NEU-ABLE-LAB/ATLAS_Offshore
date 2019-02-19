function sTab=fTablePrint(M,ColNames,RowNames,Corner,format,sep)

nRows=size(M,1);
nCols=size(M,2);

% --- String lengths
L_num = length(sprintf(format,1.0));
L_col = max(cellfun(@(x)length(x),ColNames));
L_row = max(cellfun(@(x)length(x),RowNames));

if L_num<L_col
    error('Increase length of `format` to at least %d',L_col);
end

fmtRowName=['%' num2str(L_row+1) 's' sep];
fmtColName=['%' num2str(L_num) 's'   sep];
fmtNum    =[format sep];

%% 

sTab=cell(1,nRows+1);

sTab{1}=[sprintf(fmtRowName,Corner) sprintf(fmtColName,ColNames{:})]; % Header
for i=1:nRows
    sTab{i+1}=[sprintf(fmtRowName,RowNames{i}) sprintf(fmtNum,M(i,:))];
    sTab{i+1}=strrep(sTab{i+1},'NaN',' - ');
end

