t = zeros(5, 3);
for i = 1 : 1000
    seed = randi(10)
    t = pushMRU(seed, t, 0)
end