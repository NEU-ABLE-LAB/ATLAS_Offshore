function J=toy_problem(ind,parameters,i,fig)

%% Creation of the points to fit.
s=-10:0.1:10;          
b=tanh(1.256*s)+1.2;   

%% Initialisation of b_hat as a vector.
b_hat=b*0;

%% Evaluation. 
% Evaluation is always encapsulated in try/catch.
% Structure to account for the unpredictible.

try
   % Translation from LISP.
idv_foraml=readmylisp_to_formal_MLC(ind,parameters); 
idv_formal=strrep(m,'S0','s'); % replace S0 leaf with variable s  
   % Obtention of estimated s.
eval(['b_hat=' idv_formal ';'])
   % Obtention of cost function value.
J=sum((b-b_hat).^2)/length(b);
catch err
    % If something goes wrong, asign a bad value.
    J=parameters.badvalue;
    fprintf(err.message);
end


if nargin==4
    subplot(2,1,1)
    plot(s,b,'*',s,b_hat)
    subplot(2,1,2)
    plot(s,sqrt((b-b_hat).^2),'*r')
    set(gca,'yscale','log')
end
    

