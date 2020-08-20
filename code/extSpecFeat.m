function [featMat] = extSpecFeat(tf,Idx)

    %% extracting feature from tf_all
    featMat= nan(size(tf,3),size(Idx,1));

    for ifeat=1:size(Idx,1)
        for itrial=1:size(tf,3)
            current_tf= tf(:,:,itrial);
            featMat(itrial,ifeat)= nanmean(nanmean...
                (current_tf(Idx{ifeat})));
        end
    end
    


end