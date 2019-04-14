function f=my_lyapunov_ev1(t,y)
if t==0; tic;end
Y(1,1)=y(4);
Y(1,2)=y(7);
Y(1,3)=y(10);
Y(2,1)=y(5);
Y(2,2)=y(8);
Y(2,3)=y(11);
Y(3,1)=y(6);
Y(3,2)=y(9);
Y(3,3)=y(12);
f=zeros(13,1);
if toc<30
b=zeros(3,1);
