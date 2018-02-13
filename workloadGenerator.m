function requests = workloadGenerator(types, dist)
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
requests = zeros(1, 1000);
for i = 1 : length(requests)
    r = rand * length(ratioListCDF);
    idx = sum(ratioListCDF < r) + 1;
    requests(i) = idx;
end
for i = 1 : 10
    
end
end