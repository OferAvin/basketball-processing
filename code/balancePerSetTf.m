function rmIdx = balancePerSetTf (metaData)
%balance
rmIdx = zeros(size(metaData,1),1);
[~,subs]=countAppearances(metaData(:,1));
for i= 1:size(subs,1)
    isub= subs(i);
    [~,sets]=countAppearances(metaData(metaData(:,1)==isub,2));
    for j= 1:size(sets)
        iset= sets(j);
     tempData= metaData(:,1)==isub & metaData(:,2)==iset;
     startIdx=find(tempData,1,'first');
     %
     [app,elemnt] = countAppearances(metaData(tempData,4));
     [~,maxIdx] = max(app);
     maxElemnt = elemnt(maxIdx);
     idxVec = find(metaData(tempData,4) == elemnt(maxIdx)) +startIdx -1;
     idxVec= idxVec(randperm(size(idxVec,1)));
     rmIdx (idxVec(1:abs(diff(app)))) = 1;

    %rmIdx= cat(1,rmIdx,tempData);

    end
end
%rmIdx= rmIdx ==0;
rmIdx= logical(rmIdx);
end