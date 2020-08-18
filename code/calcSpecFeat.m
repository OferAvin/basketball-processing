function [featMat,featNames] = calcSpecFeat(tf,sigMat,chan, validSize,minsize,minIntensity,wvlt_times,frex)
    
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
    %% extracting feature from tf_all
    featMat(1:size(tf,3),1:size(validregion,2))= nan;

    for ifeat=1:size(validregion,2)
        for itrial=1:size(tf,3)
            current_tf= tf(:,:,itrial);
            featMat(itrial,ifeat)= nanmean(nanmean...
                (current_tf(regionStruct(validregion(ifeat)).PixelIdxList)));
        end
    end
    
    %% feat names
    featNames={};
        for ifeat=1:size(validregion,2)
            t_start= wvlt_times(ceil(regionStruct(validregion(ifeat)).BoundingBox(1)));
            t_end= wvlt_times(floor(regionStruct(validregion(ifeat)).BoundingBox(1)) + regionStruct(validregion(ifeat)).BoundingBox(3));
            frex_start= frex(ceil(regionStruct(validregion(ifeat)).BoundingBox (2)));
            frex_end= frex(floor(regionStruct(validregion(ifeat)).BoundingBox (2)) + regionStruct(validregion(ifeat)).BoundingBox(4));
        
        featNames{ifeat}= {[chan ' ' num2str(t_start) ':' num2str(t_end) ' ms ' ...
            num2str(round(frex_start)) ':' num2str(round(frex_end)) ' Hz']};
            
        end
end