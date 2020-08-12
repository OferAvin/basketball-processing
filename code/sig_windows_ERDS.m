function StartEndIdx=sig_windows_ERDS(sig,NSigLength)

StartEndIdx= {};
for iband= 1: size(sig,1)
d= find(sig(iband,:)==1)';
StartEndIdx{iband}=[];
i=1;
while i < size(d,1)
    tempStart= d(i);
    sigLength=0;
    dif= 1;
    while dif<3 && i < size(d,1)
        sigLength=sigLength+1;
        dif= diff ([d(i) d(i+1)]);
        i=i+1;
    end
    if sigLength >NSigLength
       StartEndIdx{iband}(end+1,:)= [tempStart d(i-1)] ;
    end   
end
end
end
