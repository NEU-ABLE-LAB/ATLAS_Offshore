function []=fDispatchFigs(varargin)
% Dispatch figures over the screen(s)
% E. Branlard June 2013
%
% dispatchFigs    : no arguments: dispatch the figure on the screens without resizing figures
% dispatchFigs(0) : same as dispatchFigs without arguments
% dispatchFigs(1) : use a defaults grid on the available screen(s)
% dispatchFigs(2) : use a default grid on the laptop display (screen 2)
% dispatchFigs(3,4)  : use grid 3x4 on screen 1 
% dispatchFigs(3,4,2): use grid 3x4 on screen 2 
% dispatchFigs(3,4,2,2) : use grid 3x4 on screen 1 and 2x2 on screen two
%
%% Parameters
%
hWin=65;      %<<<<<<<< Height of matlab toolbar + window manager

% Extent of menu bars:   TODO: Make this screen-wise
xMenuBarLeft   = 140;
xMenuBarRight  = 0;
yMenuBarTop    = 0  ;
yMenuBarBottom = 0  ;



% --------------------------------------------------------------------------------
% ---  Coordinate system adopted in this script
% --------------------------------------------------------------------------------
%       ^ y
%       | 
%     
%       |---------------|
%       |               |
%       |    SCREEN     |
%       |               |
%       |---------------|  -> x
%  (xmin,ymin)
%     (0,0)
%
%
%
%
%


% --------------------------------------------------------------------------------
% --- Detecting number of screens and screens dimensions 
% --------------------------------------------------------------------------------
A  = get(0, 'ScreenSize' )    ; % should disappear
mp = get(0, 'MonitorPositions');

% --------------------------------------------------------------------------------
% --- Specific Overrides (due to some nVidia config on linux)
% --------------------------------------------------------------------------------
if(A(3)==3520 && A(4)==1080)
    % Specific case for work: Laptop right of main screen
    Laptop=[1600 900];
    mp=zeros(2,4);
    mp(1,:)=[1,1,A(3)-Laptop(1),A(4)];
    mp(2,:)=[A(3)-Laptop(1),1,Laptop(1),Laptop(2)];
end
% --------------------------------------------------------------------------------
% --- Creating screens "effective" extents  (without menu bars)
% --------------------------------------------------------------------------------
nMonitors= size(mp,1);
% S{i} = [xmin, yTopCorner, xmax, ymax]
if(nMonitors==1)
    % Parameter for the current monitor
    xmin= mp(1,1);
    ymin= mp(1,2);
    lx  = mp(1,3);
    ly  = mp(1,4);
    % Reducing these parameters according to menu bars
    S{1}=[xmin+xMenuBarLeft ymin+ly-yMenuBarTop lx-xMenuBarRight ly-yMenuBarBottom];
elseif(nMonitors==2) 
    for i = 1:nMonitors
        xmin= mp(i,1);
        ymin= mp(i,2);
        lx  = mp(i,3);
        ly  = mp(i,4);
        % Reducing these parameters according to menu bars
        S{i}=[xmin+xMenuBarLeft ymin+ly-yMenuBarTop lx-xMenuBarRight ly-yMenuBarBottom];
    end

else
    error('Script written in a naive way, generalization for n monitors todo')
end
if(nargin==0 || (nargin==1 && varargin{1}==0))
    % --------------------------------------------------------------------------------
    % --- Dispatch without resizing figs)
    % --------------------------------------------------------------------------------
    iScreen=1;
    ScreenRoom=S{1};
    figs=get(0,'children');
    for i=1:length(figs)
        hfig=figs(length(figs)-i+1);  % fig handle
        P=get(hfig,'Position');
        P(1)=ScreenRoom(1);
        P(2)=ScreenRoom(2)-P(4)-hWin;
        set(hfig,'Position',P);
        set(hfig,'Visible','on');
        ScreenRoom(1)= ScreenRoom(1)+P(3);
        if(ScreenRoom(1)+P(3)>ScreenRoom(3))
            ScreenRoom(1)=S{iScreen}(1);
            ScreenRoom(2)= ScreenRoom(2)-P(4)-hWin;
        end
         if(ScreenRoom(2)-P(4)-hWin<S{iScreen}(2)-S{iScreen}(4) )
            iScreen=mod(iScreen,nMonitors)+1;
            ScreenRoom=S{iScreen} ;
         end
     end

     % --------------------------------------------------------------------------------
     % --- Put figures on a grid 
     % --------------------------------------------------------------------------------
 elseif(nargin==1)
   % Default Grid
   switch (varargin{1}) 
       case 1
       % Default Grid on both screens
        Grid{1}=[4 3];
        if(length(S)==1)
        else
            Grid{2}=[3 2];
        end
    case 2
       % Default Grid only on the last screen
        Grid{1}=[3 2];
        S{1}=S{end}; % using only the last screen
    otherwise
        error('Argument should be 1 or 2')
    end
    setFigGrid(S,Grid,hWin)
elseif(nargin==2)
    % Using grid provided by the user on the first screen
    Grid{1}=[varargin{1} varargin{2}];
    setFigGrid(S,Grid,hWin);

elseif(nargin==3)
    % Using grid provided by the user on the screen requested by the user
    Grid{1}=[varargin{1} varargin{2}];
    S=S(varargin{3}); % that's the trick, here we select only one screen
    setFigGrid(S,Grid,hWin);
elseif(nargin==4)
  % Using grid provided by the user on screen 1 and 2
    Grid{1}=[varargin{1} varargin{2}];
    Grid{2}=[varargin{3} varargin{4}];
    setFigGrid(S,Grid,hWin);
else
    disp('wrong number or arguments');
end




% --------------------------------------------------------------------------------
% ---  
% --------------------------------------------------------------------------------
function []=setFigGrid(S,G,hWin)
nG=length(G);
%compute Grid coordinates and store them in GP
for iG=1:nG
    dx=(S{iG}(3)-S{iG}(1))/G{iG}(1);
    dy=(S{iG}(4))/G{iG}(2)-hWin;
    cpt=0;
    for iy=1:G{iG}(2)
        for ix=1:G{iG}(1)
            cpt=cpt+1;
            GP{iG}(cpt,:)=[S{iG}(1)+(ix-1)*dx  S{iG}(2)-(iy)*dy-(iy)*hWin dx dy];
        end
    end
end
% 
iG=1;
nmax=length(GP{1}(:,1));
cpt=1;
figs=get(0,'children');
for i=1:length(figs)
    hfig=figs(length(figs)-i+1);  % fig handle
    set(hfig,'Position',GP{iG}(cpt,:));
    set(hfig,'Visible','on');
    cpt=cpt+1;
    if(cpt>nmax)
        iG=mod(iG,nG)+1;
        nmax=length(GP{iG}(:,1)) ;
        cpt=1;
     end
 end



