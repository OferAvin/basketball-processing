function [allFeat,allLabels,allMetaData] = arangeLabelsForFeatMat(metaData,featMat,lable2rm,doBalance)
    rmIdx = metaData(:,4) == lable2rm;
    metaData(rmIdx,:) = [];
    featMat(rmIdx,:) = [];
    allFeat = featMat;
    allLabels = metaData(:,4);
    allMetaData= metaData;

    if doBalance
       %balance
allFeat = [];
allLables = [];
allMetaData= [];
[~,subs]=countAppearances(metaData(:,1));
for i= 1:size(subs,1)
    isub= subs(i);
    [~,sets]=countAppearances(metaData(metaData(:,1)==isub,2));
    for j= 1:size(sets)
        iset= sets(j);
        
     tempfeatMat= featMat(metaData(:,1)==isub & metaData(:,2)==iset,:);
     tempMetaData= metaData(metaData(:,1)==isub & metaData(:,2)==iset,:);
     %
     [app,elemnt] = countAppearances(tempMetaData(:,4));
     [~,maxIdx] = max(app);
     maxElemnt = elemnt(maxIdx);
     idxVec = find(tempMetaData(:,4) == elemnt(maxIdx));
     idxVec= idxVec(randperm(size(idxVec,1)));
     tempfeatMat (idxVec(1:abs(diff(app))),:) = [];
     tempMetaData (idxVec(1:abs(diff(app))),:) = [];

allFeat = cat(1,allFeat,tempfeatMat);
allMetaData = cat(1,allMetaData,tempMetaData);
    end
end
allLabels= allMetaData(:,4);
    end
end