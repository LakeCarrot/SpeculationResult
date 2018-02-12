function [t1, t2, b1, b2, p] = repl(x, t1, t2, b1, b2, p, c)
if length(t1) ~= 0 && (length(t1) > p || (ismember(b2(:,1), x) && length(t1) == p))
    [t1, tmp] = pullLRU(t1);
    b1 = pushMRU(tmp, b1);
else
    [t2, tmp] = pullLRU(t2);
    b2 = pushMRU(tmp, b2);
end
end