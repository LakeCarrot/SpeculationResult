function [t, cost] = pullTarget(x, t)
idx = find(~(t(:,1) - x));
cost = t(idx, 3);
for i = 1 : length(t)
    if t(i, 2) > t(idx, 2)
        t(i, 2) = t(i, 2) - 1;
    end
end
t(idx, 1) = 0;
t(idx, 2) = 0;
end