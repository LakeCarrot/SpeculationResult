function t = pushMRU(mru, t, cost)
flag = 1;
for i = 1 : length(t)
    if t(i, 2) <= 0 && flag
        t(i, 1) = mru;
        t(i, 2) = 1;
        t(i, 3) = cost;
        flag = 0;
    elseif t(i, 2) > 0
        t(i, 2) = t(i, 2) + 1;
    end
end
end