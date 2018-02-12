function nbrs = targetGraph(coordinates, k)
len = length(coordinates);
nbrs = zeros(len, len);
% each node pick nearest 6 neighbors
for i = 1 : len
    nbrIdx = knnsearch(coordinates(1:len~=i, :), coordinates(i, :), 'k', k);
    nbrs(i, nbrIdx) = 1;
%     for j = 1 : length(nbrIdx)
%         plot([coordinates(i, 1), coordinates(nbrIdx(j), 1)], [coordinates(i,2), coordinates(nbrIdx(j), 2)]);
%     end
end
end