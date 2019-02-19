function [Channels, ChanName, ChanUnit, FileID, DescStr] = fReadFASTAddChannels(FileName,ChannelsAdd)
% Reads a fast output file and adds additional Channels
% INPUTS:
%   FileName
%   ChannelsAdd : cell matrix (n x 2), 1st colu is Channel name, 2nd is formula
%               e.g.
%                ChannelsAdd={
%                  'RootMnormc1', 'sqrt({RootMxc1}.^2 + {RootMyc1}.^2)';
%                }
% 
% 2018/11: E. Branlard, initial implementation
%

[Channels, ChanName, ChanUnit, FileID, DescStr] = fReadFASTbinary(FileName);

% --- Computing additinoal channels based on existing ones
nNewChannels = size(ChannelsAdd,1);
NewChannels = zeros(size(Channels,1), nNewChannels);
NewChanName = cell(nNewChannels,1);
NewChanUnit = cell(nNewChannels,1);

for ic = 1:nNewChannels
    expr              = ChannelsAdd{ic,2};
    NewChanName{ic}   = ChannelsAdd{ic,1};
    NewChanUnit{ic}   = ''               ; % Not important for now
    NewChannels(:,ic) = NaN              ;

    % Making some varaibles available to the user in their expressions
    dt = Channels(2,1)  -Channels(1,1);
    T  = Channels(end,1)-Channels(1,1);

    % --- Extracting variables in exression and replacing by proper index in Channels
    NumVars    = regexp(expr,'[\{]{1}\w+[\}]{1}','match'); % Matches strings like {WS}
    for iv=1:length(NumVars)
        ID= fGetChannelID(ChanName,NumVars{iv}(2:end-1));
        expr=strrep(expr,NumVars{iv},sprintf('Channels(:,%d)',ID(1)));
    end
    % --- evaluating expression
    NewChannels(:,ic) = eval(expr);
    
end

% --- Concatenaning new channels to other ones
Channels = [Channels  NewChannels];
ChanName = [ChanName; NewChanName];
ChanUnit = [ChanUnit; NewChanUnit];



end

