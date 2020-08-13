function [selectMat,featIdx,featOrder] = selectFeat(featMat,nFeatSelect,labels)
% this function extract the n best fearures 
% Features - struct that containing all features data lables and parameters
% nFeat2Reduce = the num of feature to slect
  
    Selection = fscnca(featMat,labels);
    weights = Selection.FeatureWeights;
   
    %Decsending order of importence
    [~ , featOrder] = sort(weights, 'descend');
    %Taking the most importent features
    featIdx = featOrder(1:nFeatSelect);
    selectMat = featMat(:,(featIdx));
end