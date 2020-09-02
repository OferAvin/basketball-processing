function [featMatTrain,featMatVal,featNames,featIdx] = getAutoSpecFeat(tfTrain,tfVal,chansLables, validSize,minsize,minIntensity,wvlt_times,frex,labels_all,classes2analyze,pVal,method,bl,plotFlagTF)
% get spectogram automatic features.
% the function gets cell arrays of tf and chanLabels
% if 2 tf matrix are given- the first is train the second is val\test.
% if 1 tf matrix is given- the matrix is train matrix
% returns features matrixes

%calculate valid features indexes and name. plot if flag is 1
[featIdx,featNames] = cellfun(@(x,y) calcSpecFeat(x,y,...
    validSize,minsize,minIntensity,wvlt_times,frex,labels_all,classes2analyze...
    ,pVal,method,bl,plotFlagTF),tfTrain,chansLables,'UniformOutput',false);
featNames = cat(1,featNames{:})';

% extract tidy featMat, by mean of the given the indexes
 [featMatTrain] = cellfun(@(x,y) extSpecFeat(x,y) ,tfTrain,featIdx,'UniformOutput',false);
 featMatTrain= cat(2,featMatTrain{:});
% if val tf is exist, compute featMatVal
    if isempty(tfVal)==0
     [featMatVal] = cellfun(@(x,y) extSpecFeat(x,y) ,tfVal,featIdx,'UniformOutput',false);
     featMatVal= cat(2,featMatVal{:});
    else
        featMatVal=[];
    end
end