function [allFeat,allLables] = arangeLables(lables,featMat,lable2rm,doBalance)
    rmIdx = lables == lable2rm;
    lables(rmIdx) = [];
    featMat(rmIdx,:) = [];
    allFeat = [];
    allLables = [];
    if doBalance
        %balance
        [app,elemnt] = countAppearances(lables);
        [minApp,minIdx] = min(app);
        minElemnt = elemnt(minIdx);
        for i = 1:length(elemnt)
            idxVec = find(lables == elemnt(i));
            rnd = randperm(minApp);
            idxVec = idxVec(rnd);
            chosenTrialFeat = featMat(idxVec,:);
            chosenTrialLbls = lables(idxVec);
            allFeat = cat(1,allFeat,chosenTrialFeat);
            allLables = cat(1,allLables,chosenTrialLbls);        
        end
        shufIdx = randperm(size(allFeat,1));
        allFeat = allFeat(shufIdx,:);
        allLables = allLables(shufIdx);
    end
end