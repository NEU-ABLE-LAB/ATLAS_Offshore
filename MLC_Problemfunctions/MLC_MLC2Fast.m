function [exprs, fcnText] = MLC_MLC2Fast(indFormal, MLC_params)
%% MLC_exprs Parse MLC formal expression into Simulink domain
%
%   formal - ind.formal output of MLC
%   MLC_param - MLC paramters
%
%   exprs - strings to feed into eval() then into Simulink

% Sensor information
nSensors = MLC_params.sensors;
nStates = MLC_params.problem_variables.nStates;
exprs = indFormal;

%% Convert from MLC sensor notation to Simulink signal indexing
for exprN = 1:length(exprs)
    for sensorN = 1:nSensors

        % Replace senor name with indexed input signal
        exprs{exprN} = regexprep(exprs{exprN}, ...
            sprintf('(^|\\W)S%d(?=\\W|$)',sensorN-1),...
            sprintf('$1u(%d)',...
                MLC_params.problem_variables.sensorIdxs(sensorN)));

        % Replace `.*` with `*`
        %   Since the `fcn` Simulink blocks don't support `.*`
        exprs{exprN} = strrep(exprs{exprN},'.*','*');

    end
end

if any(contains(exprs,'$'))
    disp(exprs')
    error('MLC_eval: Expression contained ''$'' after parsing');
end

%% Create string to write to the script file

%Combine outdata and X into one vector 
fcnText = sprintf('u = [OutData; X]; \n');

%Control laws
fcnText = sprintf('%sy = [', fcnText);
for exprN = 1:length(exprs)

    if exprN ~= 1
        fcnText = sprintf('%s\t', ...
            fcnText);
    end

    fcnText = sprintf('%s\t%s', ...
        fcnText, exprs{exprN});

    if exprN ~= length(exprs)
        fcnText = sprintf('%s; \n ',...
            fcnText);
    end

end	
fcnText = sprintf('%s]; \n', fcnText);
%thetaout
fcnText = sprintf('%sThetaout = y(1:3); \n', fcnText);

%x0
fcnText = sprintf('%sX0 = [', fcnText);
for exprN = 1:nStates
    fcnText = sprintf('%s0', fcnText);
    if exprN ~= nStates
        fcnText = sprintf('%s; ',fcnText);
    end
end
fcnText = sprintf('%s]; \n', fcnText);

%xdot
fcnText = sprintf('%sXdot = [', fcnText);
for exprN = 1: nStates

    if exprN ~= 1
        fcnText = sprintf('%s\t', ...
            fcnText);
    end

    fcnText = sprintf('%s\ty(%i)', ...
        fcnText, exprN + 3);

    if exprN ~= nStates
        fcnText = sprintf('%s; \n ',...
            fcnText);
    end
end
fcnText = sprintf('%s];', fcnText);

end