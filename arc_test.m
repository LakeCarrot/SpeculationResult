%% Create a sequence of workload to each of these node
clear all; close all; clc;
types = 1000; % number of applications in total
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
requests = zeros(1, 10000);
for i = 1 : length(requests)
    r = rand * length(ratioListCDF);
    idx = sum(ratioListCDF < r) + 1;
    requests(i) = idx;
end
%% test script for ARC
for avgReq = 1 : 1: 20 % average requests per minutes
    lambda = avgReq/60;
    reqTimeline = poissrnd(lambda, 1, ceil(length(requests)/lambda));
    sum(reqTimeline)
    for c = 20 : 100
        p = 0;
        t1 = zeros(c,3);
        t2 = zeros(c,3);
        b1 = zeros(c,3);
        b2 = zeros(c,3);
        ct1 = zeros(c,3);
        ct2 = zeros(c,3);
        cb1 = zeros(c,3);
        cb2 = zeros(c,3);
        nt1 = zeros(c,3);
        nt2 = zeros(c,3);
        nb1 = zeros(c,3);
        nb2 = zeros(c,3);
        t = zeros(c, 3);
        hitRecordARC = 0;
        hitRecordLRU = 0;
        hitRecordCARC = 0;
        waitRecordARC = 0;
        waitRecordLRU = 0;
        waitRecordCARC = 0;
        pending = 0;
        counter = 0;
        delta = 0;
        timestamp = 1;
        while timestamp < length(reqTimeline)
            reqs = reqTimeline(timestamp);
            timestamp = timestamp + 1;
            delta = delta + 1;
            if reqs == 0
                continue;
            end
            for i = counter + 1 : min(counter + reqs, length(requests))
                t1 = updateCost(t1, delta);
                t2 = updateCost(t2, delta);
                t = updateCost(t, delta);
                delta = 0;
                [t1, t2, b1, b2, p, hitARC, waitARC] = arc(requests(i), t1, t2, b1, b2, p, c, 120);
                [t, hitLRU, waitLRU] = Lru(requests(i), t, c, 120);
                if hitARC == 1
                    hitRecordARC = hitRecordARC + 1;
                end
                if hitLRU == 1
                    hitRecordLRU = hitRecordLRU + 1;
                end
                waitRecordARC = waitRecordARC + waitARC;
                waitRecordLRU = waitRecordLRU + waitLRU;
            end
            if counter + reqs > length(requests)
                break;
            end
            counter = counter + reqs;
        end
        hitRatioARC(avgReq, c - 19) = hitRecordARC/min(counter, length(requests));
        hitRatioLRU(avgReq, c - 19) = hitRecordLRU/min(counter, length(requests));
        waitAvgARC(avgReq, c - 19) = waitRecordARC/min(counter, length(requests));
        waitAvgLRU(avgReq, c - 19) = waitRecordLRU/min(counter, length(requests));
    end
end
%%
for avgReq = 1 : 20
figure;
plot(1:length(hitRatioARC), hitRatioARC(avgReq, :) * 100);
hold on
plot(1:length(hitRatioLRU), hitRatioLRU(avgReq, :) * 100);
legend('ARC', 'LRU');
end
%%
for avgReq = 1 : 20
figure;
plot(1:length(waitAvgARC), waitAvgARC(avgReq, :));
hold on
plot(1:length(waitAvgLRU), waitAvgLRU(avgReq, :));
legend('ARC', 'LRU');
end
%%
for avgReq = 1 : 20
figure;
plot(20:100, hitRatioARC(11:91) * 100);
hold on
plot(20:100, hitRatioLRU(11:91) * 100);
legend('ARC', 'LRU');
end
%%
for avgReq = 1 : 20
%figure;
%plot(20:100, (hitRatioARC(11:91) - hitRatioLRU(11:91))./hitRatioLRU(11:91) * 100);
figure;
plot(20:100, (hitRatioARC(avgReq, 11:91) - hitRatioLRU(avgReq, 11:91)) * 100);
end