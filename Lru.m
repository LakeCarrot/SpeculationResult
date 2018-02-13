function [t, hit, wait] = Lru(x, t, c, cost)
tlen = find(t(:,1));
hit = 0;
if sum(ismember(t(:,1), x))
    t = makeMRU(x, t);
    xIdx = find(~(t(:,1) - x));
    xcos = t(xIdx, 3);
    if xcos == 0
        hit = 1;
    end
    wait = xcos;
else
    if tlen < c 
        t = pushMRU(x, t, cost);
    else 
        [t, tmp] = pullLRU(t);
        t = pushMRU(x, t, cost);
    end
    hit = 0;
    wait = cost;
end