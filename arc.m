function [t1,t2,b1,b2,p,hit] = arc(x,t1,t2,b1,b2,p,c)
    hit = 0;
    if sum(ismember(t1(:,1), x)) || sum(ismember(t2(:,1), x))
        % move x to MRU position in T2
        makeMRU(x, t2); 
        hit = 1;
    elseif sum(ismember(b1(:,1),x))
        theta = max(1, round(length(b2)/length(b1)));
        p = min(p + theta, c);
        [t1, t2, b1, b2, p] = repl(x, t1, t2, b1, b2, p, c);
    end
end
