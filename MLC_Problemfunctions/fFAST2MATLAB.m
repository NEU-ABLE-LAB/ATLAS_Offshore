function p = fFAST2MATLAB(filename)

if ~exist(filename,'file')
    error('File not found %s',filename)
end


% First read using fast 2 matlab
%s = FAST2Matlab(filename);
% then re-read and store all lines as cell array
%fid=fopen(filename);
%lines=textscan(fid, '%s', 'delimiter', '\n','whitespace',''); lines=lines{1};
%lines=textscan(fid, '%s', 'delimiter', '\n'); lines=lines{1};
%fclose(fid);
fid=fopen(filename);
tline = fgetl(fid);
lines = cell(0,1);
while ischar(tline)
    lines{end+1,1} = tline;
    tline = fgetl(fid);
end
fclose(fid);
%disp(length(lines))
% TODO remove empty lines at the end?
Labels = cell(1,length(lines));
Positions = nan(1,length(lines));
for i=1:length(Labels)
    Labels{i} = '';
    l = lines{i};
    if length(l)>3 && (isequal(l(1:3),'---') || isequal(l(1),'!'))
        % its' a comment
    else
        splits=strsplit(strtrim(l));
        if length(splits)>2
            Labels{i} = splits{2};
            ip = strfind(l,Labels{i});
            Positions(i) = ip(1);
        end
    end
end


%if length(lines)~=length(s.Label)
%    error('Inconsitent dimension %d %d',length(lines),length(s.Label))
%end

%
p.Label=Labels;
p.Positions=Positions;
p.Lines=lines;


