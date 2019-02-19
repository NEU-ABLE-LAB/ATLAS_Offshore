function [colrs]=fColrs(v,varargin)
% Possible calls
% M=fColrs()  : returns a nx3 matrix of RBG colors
% C=fColrs(i) : cycle through colors, modulo the number of color
% G=fColrs(i,n) : return a grey color (out of n), where i=1 is black
% Thrid argument add a switch possibility between black and white or colors:
% G=fColrs(i,n,1) : return a grey color (out of n), where i=1 is black
% G=fColrs(i,n,0) : cycle through colors

MathematicaBlue   = [63 63 153]/255  ; 
MathematicaRed    = [153 61 113]/255 ; 
MathematicaGreen  = [61 153 86]/255  ; 
MathematicaYellow = [152 140 61]/255 ; 

MathematicaLightBlue    = [159 159 204 ]/255  ; 
MathematicaLightRed  = [204 158 184 ]/255  ; 
MathematicaLightGreen = [158 204 170  ]/255 ; 


ManuDarkBlue=[0 0 0.7 ];
ManuDarkRed=[138 42 93]/255;
ManuDarkOrange=[245 131 1]/255;
ManuDarkOrange=[198 106 1]/255;
ManuLightOrange=[255 212 96]/255;


Red=[1 0 0];
Blue=[0 0 1];
Green=[0 0.6 0];
Yellow=[0.99 0.92 0];

MatlabGreen=[0 0.5 0];
MatlabCyan=[0.00000000000000e+000    750.000000000000e-003    750.000000000000e-003];
MatlabMagenta=[ 750.000000000000e-003    0.00000000000000e+000    750.000000000000e-003];
MatlabYellow=[750.000000000000e-003    750.000000000000e-003    0.00000000000000e+000];
MatlabGrey=[250.000000000000e-003    250.000000000000e-003    250.000000000000e-003];


% Table of Color used
mcolrs=[
MathematicaBlue
MathematicaGreen
ManuDarkRed
ManuDarkOrange
MathematicaLightBlue
MathematicaLightGreen
MathematicaLightRed
ManuLightOrange
Blue
Green
Red
Yellow
MatlabCyan
MatlabMagenta ];


if nargin==0
    colrs=[mcolrs;mcolrs;mcolrs;mcolrs;mcolrs];
elseif nargin==1
    % if(length(v)>1)
    %     mcolrs(mod(v-1,size(mcolrs,1))+1,:);
    % end
    if(v==0) 
        colrs=[0,0,0];
    else
        colrs=mcolrs(mod(v-1,size(mcolrs,1))+1,:);
    end
elseif nargin==2
    m=varargin{1};
    colrs=[0.55 0.55 0.55]*(v-1)/(m-1); %grayscale
elseif nargin==3 
  % then the third argument determined wheter it's BW or color
  m=varargin{1};
  bBW=varargin{2};
  if(bBW) 
    if(m==1)
      colrs=[0 0 0];
    else
      colrs=[0.55 0.55 0.55]*(v-1)/(m-1); %grayscale
    end
  else
    colrs=mcolrs(mod(v-1,size(mcolrs,1))+1,:);
  end
else
    %nargin==0
    colrs=[mcolrs;mcolrs;mcolrs;mcolrs;mcolrs];
end
end

