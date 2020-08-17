function extBPbySig(tf,chansLables,freqs,time,labels,classes,pVal)

    sigMat = calcSigMat(tf,labels,classes,pVal);
    sigMat(isnan(sigMat)) = 0;
    regionStruct = regionprops(sigMat>0,sigMat,'Area','PixelIdxList','MeanIntensity');
    
    featMat(:,ifeat) = cell2mat(arrayfun(@(x) mean(tf(regionStruct(ifeat).PixelIdxList+(nPix*(x-1)))),...
        1:size(tf,3),'UniformOutput',false))';
end