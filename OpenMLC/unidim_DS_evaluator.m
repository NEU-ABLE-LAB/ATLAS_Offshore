function J=unidim_DS_evaluator(ind,mlc_parameters,i,fig)
A=1;

Tf=mlc_parameters.problem_variables.Tf;
objective=mlc_parameters.problem_variables.objective;
gamma=mlc_parameters.problem_variables.gamma;
Tevmax=mlc_parameters.problem_variables.Tevmax;

m=readmylisp_to_formal_MLC(ind);
m=strrep(m,'S0','y');
K=@(y)(y);
eval(['K=@(y)(' m ');']);
f=@(t,y)(A*y+K(y)+testt(toc,Tevmax));
Tf=mlc_parameters.problem_variables.Tf;
objective=mlc_parameters.problem_variables.objective;
gamma=mlc_parameters.problem_variables.gamma;
%try
tic
[T,Y]=ode45(f,[0 Tf],1);
if T(end)==Tf
    
    b=Y*0+K(Y);
    Jt=1/Tf*cumtrapz(T,(Y-objective).^2+gamma*b.^2);
    J=Jt(end);
else
    J=mlc_parameters.badvalue;
end
%catch err
%   J=mlc_parameters.badvalue 
%end
    
if nargin>3
    [K,S,E]=lqr(A,1,1,1,0);
    f=@(t,y)(A*y-K*y+testt(toc,Tevmax));
    [T2,Y2]=ode45(f,[0 Tf],1);
    subplot(3,1,1)
    plot(T2,Y2,'-r','linewidth',2);hold on
    plot(T,Y,'--k','linewidth',1.2);hold off
    
   % ylabel('$a$','interpreter','latex','fontsize',20)
    subplot(3,1,2)
    plot(T2,-K*Y2,'-r','linewidth',2);hold on
    plot(T,b,'--k','linewidth',1.2);hold off
   % ylabel('$b$','interpreter','latex','fontsize',20)
    subplot(3,1,3)
    plot(T2,1/T2(end)*cumtrapz(T2,Y2.^2+(-K*Y2).^2),'-r','linewidth',2);hold on
    plot(T,Jt,'--k','linewidth',1.2);hold off
    
   % ylabel('$(a-a_0)^2+\gamma b^2$','interpreter','latex','fontsize',20)
   % xlabel('$t$','interpreter','latex','fontsize',20)
    for i=1:3
        subplot(3,1,i)
    set(gca,'fontsize',13)
    end
    set(gcf,'PaperPositionMode','auto')
set(gcf,'Position',[100 100 600 500])
end