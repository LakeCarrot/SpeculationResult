function [t, lru] = pullLRU(t)
lruIdx = find(~(t(:,2) - max(t(:,2))));
lru = t(lruIdx, 1);
t(lruIdx, 1) = 0;
t(lruIdx, 2) = 0;
end