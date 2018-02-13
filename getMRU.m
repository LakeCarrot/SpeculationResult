function mru = getMRU(t)
idx = find(~(t(:,2) - 1));
mru = t(idx, 1);
end