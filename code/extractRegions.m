function extractRegions(mat)
    
    mat(isnan(mat)) = 0;
    regionStruct = regionprops(mat>0,mat,'Area','PixelIdxList','MeanIntensity');
            
end