function feat = calcBPFeat(tf,sigMat,validSize,minsize,minIntensity)
    
    regionStruct = regionprops(sigMat>0,sigMat,'Area','PixelIdxList','MeanIntensity');
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
    %% extracting feature from tf_all
    feat(1:size(tf,3),1:size(validregion,2))= nan;

    for ifeat=1:size(validregion,2)
        for itrial=1:size(tf,3)
            current_tf= tf(:,:,itrial);
            feat(itrial,ifeat)= nanmean(nanmean...
                (current_tf(regionStruct(validregion(ifeat)).PixelIdxList)));
        end
    end
end