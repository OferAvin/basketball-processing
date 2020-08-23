function [TrainFeatMat,ValFeatMat,featNames] = rmByFeatName(names,TrainFeatMat,ValFeatMat,featNames)
    totRM = zeros(1,length(featNames));
    for name = names
        rmFeat = (cellfun(@(x) strfind(x,name),featNames,'UniformOutput',false));
        rmFeat= cat(2,rmFeat{:});
        tf = cellfun('isempty',rmFeat); % true for empty cells
        rmFeat(tf) = {0}; 
        totRM = totRM + cell2mat(rmFeat);
    end
    totRM = logical(totRM);
    TrainFeatMat(:,totRM) = [];
    ValFeatMat(:,totRM) = [];
    featNames(totRM) = [];
end