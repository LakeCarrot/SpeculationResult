%% Form a k-nearest-connected graph
clear all; close all; clc;
len = 100;
k = 6;
coordinates = rand(len,2);
scatter(coordinates(:,1),coordinates(:,2));
hold on
nbrs = targetGraph(coordinates, k);
%% Create a sequence of workload to each of these node 
types = 100; % number of applications in total
slots = 500; % number of total time slots
totalSize = 10; % the cache + prefetch storage size 
rawDownload = [1383658, 1017559, 714632, 362557, 103245 + 22328, 31661];
typeRatio = round(rawDownload / sum(rawDownload) * 100);
typeRatioCDF = zeros(1, length(typeRatio));
typeRatioCDF(1) = typeRatio(1);
for i = 2 : length(typeRatio)
    typeRatioCDF(i) = typeRatioCDF(i - 1) + typeRatio(i);
end
numberOfOccurType = rawDownload .* [50, 500, 5000, 50000, 500000, 1000000];
occurRatio = numberOfOccurType / sum(numberOfOccurType) * 100;
ratioList = zeros(1, types);
for i = 1 : types
    if i <= typeRatioCDF(1)
        ratioList(i) = occurRatio(1) / typeRatio(1);
    elseif i <= typeRatioCDF(2)
        ratioList(i) = occurRatio(2) / typeRatio(2);
    elseif i <= typeRatioCDF(3)
        ratioList(i) = occurRatio(3) / typeRatio(3);
    elseif i <= typeRatioCDF(4)
        ratioList(i) = occurRatio(4) / typeRatio(4);
    elseif i <= typeRatioCDF(5)
        ratioList(i) = occurRatio(5) / typeRatio(5);
    else
        ratioList(i) = occurRatio(6) / typeRatio(6);
    end
end
ratioListCDF = zeros(1, types);
ratioListCDF(1) = ratioList(1);
for i = 2 : types
    ratioListCDF(i) = ratioListCDF(i - 1) + ratioList(i);
end
%% 
% every 60 slots, we will update the information of prefetcher based on
% the collected results from all of my neighbors
% this is the first version with fixed size of prefetcher, obsolete
for lambda = 3 : 3 % set avg event coming frequency per second
    requestList = zeros(len, slots);
    for i = 1 : len
        requestList(i, :) = poissrnd(lambda, 1, slots);
    end
    for ratio = 0.1 : 0.1 : 0.9 % set the ratio of isolated prefetcher
        totalRequest = 0;
        hitRequest = 0;
        cacheSize = ceil(totalSize * ratio);
        prefetchSize = totalSize - cacheSize;
        prefetchTable = zeros(len, prefetchSize);
        cacheTable = zeros(len, cacheSize);
        historyHitMap = zeros(len, types);
        for round = 1 : slots
            hitMap = zeros(len, types);
            if mod(round, 60) == 0
                prefetchTable = updatePrefetchTable(nbrs, prefetchTable, ...
                    len, types, prefetchSize, hitMap, historyHitMap);
                hitRate = hitRequest / totalRequest
            end
            for node = 1 : len
                reqs = requestList(i, round);
                totalRequest = totalRequest + reqs;
                for req = 1 : reqs
                    r = rand * length(ratioListCDF);
                    idx = sum(ratioListCDF < r) + 1;
                    hitMap(node, idx) = hitMap(node, idx) + 1;
                    if sum(ismember(prefetchTable(node, :), idx))
                        hitRequest = hitRequest + 1;
                    elseif sum(ismember(cacheTable(node, :), idx))
                        hitRequest = hitRequest + 1;
                        if(cacheSize >= 2)
                            cacheTable(node, 2:cacheSize) = cacheTable(node, 1:cacheSize-1);
                        end
                        cacheTable(node, 1) = idx;
                    else
                        if(cacheSize >= 2)
                            cacheTable(node, 2:cacheSize) = cacheTable(node, 1:cacheSize-1);
                        end
                        cacheTable(node, 1) = idx;
                    end
                end
            end
        end
        hitRate = hitRequest / totalRequest
    end
end

%% LRU vs. ARC vs. C-ARC