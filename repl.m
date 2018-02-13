function [t1, t2, b1, b2, p] = repl(x, t1, t2, b1, b2, p, cost)
t1len = length(find(t1(:,1)));
if t1len ~= 0 && (t1len > p || (sum(ismember(b2(:,1), x)) == 1 && t1len == p))
    [t1, tmp] = pullLRU(t1);
    b1 = pushMRU(tmp, b1, cost);
else
    [t2, tmp] = pullLRU(t2);
    b2 = pushMRU(tmp, b2, cost);
end
end