function t = updateCost(t, delta)
for i =  1 : length(t)
    if t(i, 1) > 0 && t(i,3) > 0
        t(i, 3) = max(t(i, 3) - delta, 0);
    end
end
end
