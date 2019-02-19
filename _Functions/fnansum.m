function s=fnansum(x)
    % nansum, if not available
    s=sum(x(~isnan(x)));
end
