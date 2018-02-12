function t = pushMRU(mru, t, cost)
for i = 1 : length(t)
    if t(i, 2) <= 0
        t(i, 1) = mru;
        t(i, 2) = 1;
        t(i, 3) = cost;
    else
        t(i, 2) = 
    end
end
end