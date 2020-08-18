function plotDiffandPval(tf,chan,sigMat,wvlt_times,frex,labels_all,pVal,classes)
    good = tf(:,:,labels_all==classes(1));
    bad = tf(:,:,labels_all==classes(2));
       
    figure('Units','normalized','Position',[0.06,0.08,0.9,0.78])
    suptitle(chan); %   sgtitle(chan);
    subplot(2,1,1);
    imagesc(wvlt_times,frex,nanmean(good,3)-nanmean(bad,3));
     set(gca, 'CLimMode', 'auto')
    title ('                                                                mean diff (g-b) ALL');
    colorbar();
   % caxis([-2 2])
    colormap(jet);
    axis xy;

    %plot significance
    subplot(2,1,2);
    imagesc(wvlt_times,frex,sigMat);
    set(gca, 'CLimMode', 'auto')
    title (char("p < " + pVal));
    colorbar();
    colormap(jet);
    axis xy;
end