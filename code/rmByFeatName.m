function [featMat,featNames] = rmByFeatName(names,featMat,featNames)
    totRM = zeros(1,length(featNames));
    for name = names
        rmFeat = (cellfun(@(x) strfind(x,name),featNames,'UniformOutput',false));
        rmFeat= cat(2,rmFeat{:});
        tf = cellfun('isempty',rmFeat); % true for empty cells
        rmFeat(tf) = {0}; 
        totRM = totRM + cell2mat(rmFeat);
    end
    totRM = logical(totRM);
    featMat(:,totRM) = [];
    featNames(totRM) = [];
end