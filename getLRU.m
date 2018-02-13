function lru = getLRU(t)
idx = find(~(t(:,2) - max(t(:,2))));
lru = t(idx, 1);
end