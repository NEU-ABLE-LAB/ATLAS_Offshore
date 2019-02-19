function Val=fGetVal(S,Label);

iFound=[];
for i = 1:length(S.Label)
    if isequal(S.Label{i}, Label)
%         if bMulti
%             iFound=[iFound,i];
%         else
        iFound=i;
        break
%         end
    end
end
if length(iFound)<=0
    error('Label not found')
end

i=iFound;
l = S.Lines{i};
ip = strfind(l,S.Label{i})-1;
if ip<=0;
    error('Label not found in line');
end
Val=l(1:ip);
