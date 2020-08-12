function plotDiffandPval(tf,chan,wvlt_times,frex,labels_all,pVal)
    good = tf(:,:,labels_all==8);
    bad = tf(:,:,labels_all==9);
    
    shuffleGood= randperm(size(good,3)); % balance the data
    good= good(:,:,shuffleGood(1:size(bad,3))); %balance the data
    
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
    sig = zeros(size(tf,1),size(tf,2));
    for i=1:size(tf,1)
        for j=1:size(tf,2)
       [~,sig(i,j)]= ttest2(bad(i,j,:),good(i,j,:));    
        end
    end
    sig(sig > pVal) = NaN;
    sig= 1-sig;
    subplot(2,1,2);
    imagesc(wvlt_times,frex,sig);
    set(gca, 'CLimMode', 'auto')
    title (char("p < " + pVal));
    colorbar();
    colormap(jet);
    axis xy;
end