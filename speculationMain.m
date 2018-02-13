%% Form a k-nearest-connected graph
clear all; close all; clc;
len = 10;
k = 6;
coordinates = rand(len,2);
nbrs = targetGraph(coordinates, k);
%% Create a sequence of workload to each of these node
types = 500; % number of applications in total
rawDownload = [1383658, 1017559, 714632, 362557, 103245 + 22328, 31661];
typeRatio = round(rawDownload / sum(rawDownload) * types);
typeRatioCDF = zeros(1, length(typeRatio));
typeRatioCDF(1) = typeRatio(1);
for i = 2 : length(typeRatio)
    typeRatioCDF(i) = typeRatioCDF(i - 1) + typeRatio(i);
end
numberOfOccurType = rawDownload .* [50, 500, 5000, 50000, 500000, 1000000];
occurRatio = numberOfOccurType / sum(numberOfOccurType) * types;
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
requests = zeros(len, 10000);
for j = 1 : len
    for i = 1 : length(requests(j, :))
        r = rand * length(ratioListCDF);
        idx = sum(ratioListCDF < r) + 1;
        requests(j,i) = idx;
    end
end
% TODO there are some minor bugs in the ratioListCDF generation part
%% LRU vs. ARC vs. C-ARC
for avgReq = 10 : 1: 10 % average requests per minutes
    lambda = avgReq/60;
    for i = 1 : len
        reqTimeline(i, :) = poissrnd(lambda, 1, ceil(10000/lambda));
    end
    avgReq
    for c = 5 : 50
        c 
        p = zeros(len);
        cp = zeros(len);
        t1 = zeros(len,c,3);
        t2 = zeros(len,c,3);
        b1 = zeros(len,c,3);
        b2 = zeros(len,c,3);
        ct1 = zeros(len,c,3);
        ct2 = zeros(len,c,3);
        cb1 = zeros(len,c,3);
        cb2 = zeros(len,c,3);
        prefetcher = zeros(len, ceil(c*0.1));
        t = zeros(len, c, 3);
        hitRecordARC = 0;
        hitRecordLRU = 0;
        hitRecordCARC = 0;
        waitRecordARC = 0;
        waitRecordLRU = 0;
        waitRecordCARC = 0;
        counter = zeros(1, len);
        delta = zeros(1, len);
        timestamp = 0;
        while timestamp < ceil(10000/lambda)
            timestamp = timestamp + 1;
            % every 60 second perform a prefetching
            if mod(timestamp, 90) == 0
                for node = 1 : len
                    ndrIdx = find(nbrs(node, :));
                    prefetchCand = [];
                    for j = 1 : length(ndrIdx)
                        if ~isempty(find(ct2(ndrIdx(j), :, 1))) 
                            prefetchCand = horzcat(squeeze(ct2(ndrIdx(j), :, 1)), prefetchCand);
                        else
                            prefetchCand = horzcat(squeeze(ct1(ndrIdx(j), :, 1)), prefetchCand);
                        end
                    end
                    prefetchChoice = mode(prefetchCand(find(prefetchCand)));
%                     if sum(ismember(ct1(:,1), prefetchChoice)) || sum(ismember(ct1(:,1), prefetchChoice)) 
%                         'in!'
%                     else
%                         'new!'
%                     end
                    [ct1(node,:,:), ct2(node,:,:), cb1(node,:,:), cb2(node,:,:), cp(node), hitCARC, waitCARC] ...
                        = arc(prefetchChoice, ...
                        squeeze(ct1(node,:,:)), squeeze(ct2(node,:,:)), ...
                        squeeze(cb1(node,:,:)), squeeze(cb2(node,:,:)), ...
                        cp(node), c, 90);
                end
            end
            for node = 1 : len
                reqs = reqTimeline(node, timestamp);
                if counter(node) + reqs > length(requests(node, :))
                    break;
                end
                delta(node) = delta(node) + 1;
                if reqs == 0
                    continue;
                end
                for i = counter(node) + 1 : counter(node) + reqs
                    t1(node,:,:) = updateCost(squeeze(t1(node,:,:)), delta(node));
                    t2(node,:,:) = updateCost(squeeze(t2(node,:,:)), delta(node));
                    ct1(node,:,:) = updateCost(squeeze(ct1(node,:,:)), delta(node));
                    ct2(node,:,:) = updateCost(squeeze(ct2(node,:,:)), delta(node));
                    t(node,:,:) = updateCost(squeeze(t(node,:,:)), delta(node));
                    delta(node) = 0;
                    [t1(node,:,:), t2(node,:,:), b1(node,:,:), b2(node,:,:), p(node), hitARC, waitARC] ...
                        = arc(requests(node, i), ...
                        squeeze(t1(node,:,:)), squeeze(t2(node,:,:)), ...
                        squeeze(b1(node,:,:)), squeeze(b2(node,:,:)), ...
                        p(node), c, 90);
                    [ct1(node,:,:), ct2(node,:,:), cb1(node,:,:), cb2(node,:,:), cp(node), hitCARC, waitCARC] ...
                        = arc(requests(node, i), ...
                        squeeze(ct1(node,:,:)), squeeze(ct2(node,:,:)), ...
                        squeeze(cb1(node,:,:)), squeeze(cb2(node,:,:)), ...
                        cp(node), c, 90);
                    [t(node,:,:), hitLRU, waitLRU] = ...
                        Lru(requests(node, i), squeeze(t(node,:,:)), c, 90);
                    if hitARC == 1
                        hitRecordARC = hitRecordARC + 1;
                    end
                    if hitLRU == 1
                        hitRecordLRU = hitRecordLRU + 1;
                    end
                    if hitCARC == 1
                        hitRecordCARC = hitRecordCARC + 1;
                    end
                    waitRecordARC = waitRecordARC + waitARC;
                    waitRecordLRU = waitRecordLRU + waitLRU;
                    waitRecordCARC = waitRecordCARC + waitCARC;
                end
                counter(node) = counter(node) + reqs;
            end
        end
        hitRatioARC(avgReq - 9, c - 4) = hitRecordARC/sum(counter);
        hitRatioLRU(avgReq - 9, c - 4) = hitRecordLRU/sum(counter);
        hitRatioCARC(avgReq - 9, c - 4) = hitRecordCARC/sum(counter);
        waitAvgARC(avgReq - 9, c - 4) = waitRecordARC/sum(counter);
        waitAvgLRU(avgReq - 9, c - 4) = waitRecordLRU/sum(counter);
        waitAvgCARC(avgReq - 9, c - 4) = waitRecordCARC/sum(counter);
    end
end
%%
for avgReq = 10 : 10
    figure;
    plot(5 : 50, hitRatioARC(avgReq - 9, :) * 100);
    hold on
    %plot(5 : 50, hitRatioLRU(avgReq - 9, :) * 100);
    plot(5 : 50, hitRatioCARC(avgReq - 9, :) * 100);
    %legend('ARC', 'LRU', 'CARC');
    legend('ARC', 'LRU')
    ylabel('Ratio (%)');
    xlabel('Cache Size');
    title('Lambda = 1/6');
end
%%
for avgReq = 10 : 10
    figure;
    plot(5 : 50, waitAvgARC(avgReq - 9, :));
    hold on
    %plot(5 : 50, waitAvgLRU(avgReq - 9, :));
    plot(1:length(waitAvgCARC), waitAvgCARC(avgReq - 9, :));
    legend('ARC', 'LRU');
    ylabel('Average Waiting Time (s)');
    xlabel('Cache Size');
    title('Lambda = 1/6');
end
% %%
% for avgReq = 10 : 10
%     figure;
%     plot(20:50, (hitRatioARC(avgReq - 9, :) - hitRatioLRU(avgReq - 9, :))./hitRatioLRU(avgReq - 9, :) * 100);
%     ylabel('ARC Relative Performance Gain');
%     xlabel('Cache Size');
%     title('Lambda = 1/6');
%     figure;
%     plot(20:50, (hitRatioARC(avgReq - 9, :) - hitRatioLRU(avgReq - 9, :)) * 100);
%     ylabel('ARC Absolute Performance Gain');
%     xlabel('Cache Size');
%     title('Lambda = 1/6');
%     figure;
%     plot(20:50, (hitRatioCARC(avgReq - 9, :) - hitRatioLRU(avgReq - 9, :))./hitRatioLRU(avgReq - 9, :) * 100);
%     ylabel('CARC Relative Performance Gain');
%     xlabel('Cache Size');
%     title('Lambda = 1/6');
%     figure;
%     plot(20:50, (hitRatioCARC(avgReq - 9, :) - hitRatioLRU(avgReq - 9, :)) * 100);
%     ylabel('ARC Absolute Performance Gain');
%     xlabel('Cache Size');
%     title('Lambda = 1/6');
% end