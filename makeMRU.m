function t = makeMRU(x, t)
idx = find(~(t(:,1) - x));
for i = 1 : length(t)
    if t(i, 2) < t(idx, 2) && t(i, 2) > 0 
        t(i, 2) = t(i, 2) + 1;
    end
end
t(idx, 2) = 1;
end