function show_convergence(mlc,nhisto,Jmin,Jmax,linlog,maxsat,gen_range,axis)
%SHOW_CONVERGENCE    Method of the MLC class. Graphs cost repartition.
%
%   MLC_OBJ.SHOW_CONVERGENCE 
%   MLC_OBJ.SHOW_CONVERGENCE(NHISTO,JMIN,JMAX,LINLOG,MAXSAT)
%   MLC_OBJ.SHOW_CONVERGENCE(NHISTO,JMIN,JMAX,LINLOG,MAXSAT,RANGE) display
%   2D or 3D histogram. 
%
%   NHISTO       - number of bins for the histograms (default 1000).
%   JMIN         - minimum cost value included (default 0).
%   JMAX         - maximum cost value included (default maximum in the
%                  data).
%   LINLOG       - logarithmic (0) or linear (1) spacing of the bins
%                  (default 0).
%   MAXSAT       - % of individuals at which the colormap saturates 
%                  (default 10).
%   RANGE        - index of population to use (default 1:end).
%
%   If only one generation is present the histogram is 2D, 3D otherwise.
%
%   See also MLC, SHOW_STATS, STATS, SHOW_TREEDEPTH
%
%   Copyright (C) 2013 Thomas Duriez (thomas.duriez@gmail.com)
%   This file is part of the TUCOROM MLC Toolbox
if nargin<2
     
     ngen=length(mlc.population);
        if min(mlc.population(ngen).fitnesses)==-1
            ngen=ngen-1;
        end
    nhisto=1000;
    Jmax=max(mlc.population(ngen).fitnesses(mlc.population(ngen).fitnesses<mlc.parameters.badvalue));
    Jmin=min(mlc.population(ngen).fitnesses);
    linlog=0;
    maxsat=1;
elseif (nargin>1 && nargin <6) || nargin >8 
    disp('Correct calls:')
    disp('mlc_obj.show_convergence')
    disp('mlc_obj.show_convergence(nhisto,Jmin,Jmax,linlog,maxsat)')
    disp('mlc_obj.show_convergence(nhisto,Jmin,Jmax,linlog,maxsat,gen_range)')
    return
end
pop=mlc.population;
if nargin>=7
    pop=pop(gen_range);
else
    ngen=length(pop);
    gen_range=1:ngen;
end
if nargin==8
    axes(axis)
else
    figure(666)
end
    
    if min(pop(length(pop)).fitnesses)==-1
       
        pop=pop(1:length(pop)-1);
    end
    nb=length(pop(1).fitnesses);
    J=zeros(nb,length(pop));
    for i=1:length(pop)
        J(:,i)=pop(i).fitnesses;
    end
      % J=1./J-1; % From adjusted fitness to goal functional
     
     nind=size(J,1);
     ngen=size(J,2);
     %% Construction of bins
     if linlog==0
         Jmax=10^ceil(log10(Jmax));
         Jmin=10^floor(log10(Jmin));
        %range=log10(max(J(J(:)<Jmax)))-log10(min(J(J(:)>max(Jmin,0))));
        %binhisto=10.^(linspace(log10(min(J(J(:)>max(Jmin,0))))-range*0.1,log10(max(J(J(:)<Jmax)))+range*0.1,nhisto));    
        binhisto=10.^linspace(floor(log10(min(J(J(:)>max(Jmin,0))))),ceil(log10(max(J(J(:)<Jmax)))),nhisto);   
     else
        range=(max(J(J(:)<Jmax)))-(min(J(J(:)>Jmin)));
        binhisto=linspace((min(J(J(:)>Jmin)))-range*0.1,(max(J(J(:)<Jmax)))+range*0.1,nhisto);
        
     end
     
     %% Construction of histograms
     histo=zeros(length(binhisto),ngen);
     for i=1:ngen
        c=hist((J(:,i)),binhisto);
        histo(:,i)=c/nind*100;
     end
     
   
      if length(pop)>=2
     %% Plot
     hgen=repmat(1:ngen,[nhisto-1 1]);
     hs=surf(hgen,repmat(binhisto(1:end-1)',[1 ngen]),histo(1:end-1,:),log(1+histo(1:end-1,:)));view(0,90);shading interp
     hold on
     %set(hs,'facealpha',0.6)
     for i=1:ngen-1
      %   plot3(ones(size(binhisto(1:end-1)))*i,binhisto(1:end-1),histo(1:end-1,i),'b','linewidth',2);
     end
     %plot3(ones(size(binhisto(1:end-1)))*ngen,binhisto(1:end-1),histo(1:end-1,ngen),'r','linewidth',2);
     hold off
     set(gca,'xlim',[1 ngen],'ylim',[min(binhisto(:)),max(binhisto(:))],'zlim',[0 max(max(histo(1:end-1,:)))+1],'clim',[-1/5 maxsat]);
  %   xlabel('n (generation index)','Interpreter','latex','fontsize',30);
  %   ylabel('J','Interpreter','latex','fontsize',30);
     set(gcf,'color',[1 1 1]);
     %box on
     set(gca,'fontsize',14,'linewidth',1.2);
     if linlog==0
         set(gca,'yscale','log');
     end
     load my_default_colormap c
     colormap(c);
     %clb=colorbar;set(clb,'fontsize',20,'linewidth',2,'fontweight','bold')
    % t=title('Population repartition (\%)');set(t,'interpreter','latex','fontsize',30)
        view(0,90)


if strcmp(mlc.parameters.selectionmethod,'tournament')
    tsize=mlc.parameters.tournamentsize;
    prob_sel=tsize*((mlc.parameters.size-(1:mlc.parameters.size))/(mlc.parameters.size-1)).^(tsize-1);
    [~,k]=min(abs(cumtrapz(prob_sel)-mlc.parameters.size*0.99));

for i=1:ngen
bestJ(i)=pop(i).fitnesses(1);
medJ(i)=median(pop(i).fitnesses);
selJ(i)=pop(i).fitnesses(k);
end
try
        heval=@(a,b,c,d)(a+b+c+d);
        eval(['heval=@' mlc.parameters.evaluation_function ';']);
        J0=feval(heval,'0',mlc.parameters,1);
      %  hold on;plot3([1:ngen],(1:ngen)*0+J0,(1:ngen)*0+max(max(histo(1:end-1,:)))+1,'--r','linewidth',1.2)
%        hold on;plot3([1:ngen;1:ngen;1:ngen;1:ngen]',[bestJ;medJ;(1:ngen)*0+J0;selJ]',[bestJ;bestJ;medJ;selJ]'*0+max(max(histo(1:end-1,:)))+1,'linewidth',2)
  
        hold off
catch
    fprintf('Can''t display J0 value due to evaluator\nExpect it to be fixed some day\n')
    hold on;plot3([1:ngen;1:ngen;1:ngen]',[bestJ;medJ;selJ]',[bestJ;medJ;selJ]'*0+max(max(histo(1:end-1,:)))+1,'linewidth',2)
  hold off
end

      
    else
     plot(binhisto,histo);
     %   xlabel('J','Interpreter','latex','fontsize',30);
     %    ylabel('N','Interpreter','latex','fontsize',30);
         set(gca,'xlim',[min(binhisto(:)),max(binhisto(:))]);
         set(gcf,'color',[1 1 1]);
     box on
     if linlog==0
         set(gca,'xscale','log');
     end
     end
      
      set(gca,'fontsize',13,'Xtick',[max(min(gen_range),1) min(max(gen_range),5):5:max(gen_range)])
    set(gcf,'PaperPositionMode','auto')
set(gcf,'Position',[100 100 600 500])
hold off    
end
    
            
    
