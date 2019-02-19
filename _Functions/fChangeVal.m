function Sout=fChangeVal(S,Label,Value,bMulti)
if ~exist('bMulti','var'); bMulti = false; end

iFound=[];
for i = 1:length(S.Label)
    if isequal(S.Label{i}, Label)
        if bMulti
            iFound=[iFound,i];
        else
            iFound=i;
            break
        end
    end
end
if length(iFound)<=0
    error('Label not found')
end

Sout = S;
for i = iFound
    %Sout.Val{iFound,1} = Value
    l = Sout.Lines{i};
    p = Sout.Positions(i);

    if isnumeric(Value)
        Value=num2str(Value);
    end
    lnew=[Value ' ' l(p:end)];
    Sout.Lines{i}=lnew;

    ip = strfind(lnew,Sout.Label{i});
    Sout.Positions(i) = ip(1);
end


