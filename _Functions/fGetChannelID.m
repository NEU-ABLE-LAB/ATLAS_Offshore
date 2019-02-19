function i=fGetChannelID(Channels,x)
    i=find(ismember(Channels,x));
    if isempty(i); 
        error('Cannot find channel %s.',x);
    end
end
