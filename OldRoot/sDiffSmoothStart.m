function dx = sDiffSmoothStart(~,x,~,~,Parameter)

dx = fDiffSmoothStart(x,10)/Parameter.Time.dt;
dx = dx(end);