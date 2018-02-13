function [t1, t2, b1, b2, p, hit, wait] = arc(x, t1, t2, b1, b2, p, c, cost)
    hit = 0;
    b1len = length(find(b1(:,1)));
    b2len = length(find(b2(:,1)));
    t1len = length(find(t1(:,1)));
    t2len = length(find(t2(:,1)));
    if sum(ismember(t1(:,1), x)) 
        [t1,xcos] = pullTarget(x, t1);
        t2 = pushMRU(x, t2, xcos);
        if xcos == 0
            hit = 1;
        end
        wait = xcos;
    elseif sum(ismember(t2(:,1), x))
        % move x to MRU position in T2
        t2 = makeMRU(x, t2); 
        xIdx = find(~(t2(:,1) - x));
        xcos = t2(xIdx, 3);
        if xcos == 0
            hit = 1;
        end
        wait = xcos;
    elseif sum(ismember(b1(:,1),x))
        theta = max(1, round(b2len/b1len));
        p = min(p + theta, c);
        [t1, t2, b1, b2, p] = repl(x, t1, t2, b1, b2, p, cost);
        [b1, tmp] = pullTarget(x, b1);
        t2 = pushMRU(x, t2, cost);
        hit = 0.5;
        wait = cost;
    elseif sum(ismember(b2(:,1),x))
        theta = max(1, round(b1len/b2len));
        p = max(p - theta, 0);
        [t1, t2, b1, b2, p] = repl(x, t1, t2, b1, b2, p, cost);
        [b2, tmp] = pullTarget(x, b2);
        t2 = pushMRU(x, t2, cost);
        hit = 0.5;
        wait = cost;
    else
        if t1len + b1len == c
            if t1len < c
                b1 = pullLRU(b1);
                [t1, t2, b1, b2, p] = repl(x, t1, t2, b1, b2, p, cost);
            else
                t1 = pullLRU(t1);
            end
        elseif t1len + b1len + t2len + b2len > c
            [t1, t2, b1, b2, p] = repl(x, t1, t2, b1, b2, p, cost);
        elseif t1len + b1len + t2len + b2len == 2 * c
            b2 = pullLRU(b2);
            [t1, t2, b1, b2, p] = repl(x, t1, t2, b1, b2, p, cost);
        end
        t1 = pushMRU(x, t1, cost);
        wait = cost;
    end
end
