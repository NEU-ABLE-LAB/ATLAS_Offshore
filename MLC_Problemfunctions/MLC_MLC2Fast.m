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
%prealocate, nessesary for simulink to identify signal sizes
fcnText = sprintf('Thetaout = [0;0;0]; \n');

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
for exprN = 1:nStates
    fcnText = sprintf('%s0', fcnText);
    if exprN ~= nStates
        fcnText = sprintf('%s; ',fcnText);
    end
end
fcnText = sprintf('%s]; \n', fcnText);

%Combine outdata and X into one vector 
fcnText = sprintf('%su = [OutData; X]; \n', fcnText);

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
fcnText = sprintf('%sThetaout(1) = y(1); \n', fcnText);
fcnText = sprintf('%sThetaout(2) = y(2); \n', fcnText);
fcnText = sprintf('%sThetaout(3) = y(3); \n', fcnText);

%xdot

for exprN = 1: nStates
    fcnText = sprintf('%sXdot(%i) = y(%i); \n', fcnText, exprN, exprN + 3);
end


end