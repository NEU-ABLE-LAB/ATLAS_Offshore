function [exprs, fcnText] = MLC_exprs(formal, MLC_params)
%% MLC_exprs Parse MLC formal expression into Simulink domain
%
%   formal - ind.formal output of MLC
%   MLC_param - MLC paramters
%
%   exprs - strings to feed into eval() then into Simulink

% Sensor information
nSensors = MLC_params.sensors;

% Extract expression for each controller
exprs = formal;

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
fcnText = sprintf('function y = fcn(u) \n');
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
fcnText = sprintf('%s];', fcnText);