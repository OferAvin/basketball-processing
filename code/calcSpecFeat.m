function [featIdx,featNames] = calcSpecFeat(tf,chan, validSize,minsize,minIntensity,wvlt_times,frex,labels,classes,pVal,plotFlag)
% this function get a tf matrix, calculate pVal and deside which areas will
% be features.
% the func returns the featIdx: the erae that need to be extracted and
% sumes into a feature, and returns the name of the corresponding feature.
% the function can plot the spectogram and the pval matrix.


    sigMat = calcSigMat(tf,labels,classes,pVal);
    regionStruct = regionprops(sigMat>0,sigMat,'Area','PixelIdxList','MeanIntensity','BoundingBox');
    Nregion= size(regionStruct,1);
    %% checking if region is valid to be a feature
    validregion = zeros(1,Nregion);
    for iregion = 1:Nregion
        if regionStruct(iregion).Area > validSize
            validregion(iregion)= iregion;
        elseif (regionStruct(iregion).Area > minsize) &&...
               (regionStruct(iregion).MeanIntensity > minIntensity)
            validregion(iregion)= iregion;
        end     
    end
    validregion(validregion == 0) = [];

    %% compute feature indexes and feat names
    featNames=cell(size(validregion,2),1);
    featIdx=cell(size(validregion,2),1);

        for ifeat=1:size(validregion,2)
            % feature indexes
            featIdx{ifeat} = regionStruct(validregion(ifeat)).PixelIdxList;
            % names
            t_start= wvlt_times(ceil(regionStruct(validregion(ifeat)).BoundingBox(1)));
            t_end= wvlt_times(floor(regionStruct(validregion(ifeat)).BoundingBox(1)) + regionStruct(validregion(ifeat)).BoundingBox(3));
            frex_start= frex(ceil(regionStruct(validregion(ifeat)).BoundingBox (2)));
            frex_end= frex(floor(regionStruct(validregion(ifeat)).BoundingBox (2)) + regionStruct(validregion(ifeat)).BoundingBox(4));
        
        featNames{ifeat}= {[chan ' ' num2str(t_start) ':' num2str(t_end) ' ms ' ...
            num2str(round(frex_start)) ':' num2str(round(frex_end)) ' Hz']};
            
        end
%% plot
if plotFlag==1
plotDiffandPval(tf,chan,sigMat,wvlt_times,frex,labels,pVal,classes)
end

end