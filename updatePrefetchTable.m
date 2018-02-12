function prefetchTable = updatePrefetchTable(nbrs, prefetchTable, ...
    len, types, prefetchSize, hitMap, historyHitMap)
for node = 1 : len
    hitRow = zeros(1, types);
    nbrIdx = find(nbrs(node, :));
    for i = 1 : length(nbrIdx)
        hitRow = hitRow + hitMap(nbrIdx(i), :);
    end
    historyHitMap(node, :) = 0.5 * historyHitMap(node, :) + 0.5 * hitRow;
    prefetchCand = find(historyHitMap(node, :));
    prefetchFreq = historyHitMap(node, prefetchCand);
    [tmp, preIdx] = sort(prefetchFreq, 'descend');
    if length(prefetchCand) < prefetchSize
        prefetchTable(node, 1 : length(prefetchCand)) = prefetchCand;
    else
        prefetchTable(node, :) = prefetchCand(preIdx);
    end
end
end