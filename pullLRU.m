function [t, lru] = pullLRU(t)
len = length(t);
for i = 1 : len
    if t(i, 2) == 1 
        lru = t(i, 1);
        t(i, 2) = 0;
    else
        t(i, 2) = t(i, 2) - 1;
    end
end
end