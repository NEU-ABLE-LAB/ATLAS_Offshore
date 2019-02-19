function frotatextick(a)
if exist('OCTAVE_VERSION', 'builtin') ~= 0
    % Octave
    xtick      = get(gca,'xtick');
    xticklabel = get(gca,'xticklabel');
    h = get(gca,'xlabel');
    xlabelstring   = get(h,'string');
    xlabelposition = get(h,'position');
    yposition = xlabelposition(2)*0.2;
    yposition = repmat(yposition,length(xtick),1);
    set(gca,'xtick',[]);
    % somekind of bug, only 90 deg works
    if a>0; a=90; end;
    hnew = text(xtick, yposition, xticklabel,'rotation',a,'horizontalalignment','right');
else
    % matlab
     xtickangle(a);
end
