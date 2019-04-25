function y = fCtrlExpr(u,expr1,expr2,expr3)
%% fCtrlExpr Calculates control within Simulink
%
%   u - vector of sensor values
%
%   expr - a string specifying a command to run on the variables u. This
%   string may be specified as each character converted to double
y = zeros(1,3);

% Force expressions to be row vectors of characters
exprStr1 = char(expr1(:)');
exprStr2 = char(expr2(:)');
exprStr3 = char(expr3(:)');

y(1:3) = eval([ '[' exprStr1 ';' exprStr2 ';' exprStr3 ']' ]);