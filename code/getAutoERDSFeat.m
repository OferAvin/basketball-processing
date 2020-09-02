function [ERDSFeatMatTrain,ERDSFeatMatVal,ERDSFeatNames] = getAutoERDSFeat(ERDSTrain,ERDSVal,chansLables,labels_all,wvlt_times,bandNames,pVal,method,plotFlag)
%get auto ERDS Feat (the ones that are significant) 
[ERDSStartEndIdx,ERDSFeatNames] = cellfun(@(x,y) ERDS_ExtFeat_Idx_Names_Plots...
    (x,y,wvlt_times,labels_all,pVal,bandNames,method,plotFlag),ERDSTrain,chansLables,'UniformOutput',false);
  
ERDSFeatNames= cat(2,ERDSFeatNames{:});


ERDSFeatMatTrain = cellfun(@(x,y) ERDS_Ext_FeatMat(x,y),ERDSTrain,ERDSStartEndIdx,'UniformOutput',false);
ERDSFeatMatTrain= cat(2,ERDSFeatMatTrain{:});

% if val tf is exist, compute featMatVal
    if isempty(ERDSVal)==0
     ERDSFeatMatVal = cellfun(@(x,y) ERDS_Ext_FeatMat(x,y),ERDSVal,ERDSStartEndIdx,'UniformOutput',false);
     ERDSFeatMatVal= cat(2,ERDSFeatMatVal{:});

    else
        ERDSFeatMatVal=[];
    end
end
