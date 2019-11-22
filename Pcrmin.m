function Critical = Pcrmin(L,q)
    y=q(2:end-1);
    delta1=q(2:end-1)-q(1:end-2);
    delta2=q(2:end-1)-q(3:end);
    delta=delta1.*delta2;
    min=y(delta>0&delta1<0);
    if length(min)==1
        minindex1 = find(y==min(1))+1;
        LcrL = L(minindex1);
        qcrL = min(1);
        Critical = [LcrL qcrL 0 0];
    else
        minindex1 = find(y==min(1))+1;
        minindex2 = find(y==min(2))+1;
        LcrL = L(minindex1);
        qcrL = min(1);
        LcrD = L(minindex2);
        qcrD = min(2);
        Critical = [LcrL qcrL LcrD qcrD];
    end
end