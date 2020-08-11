close all;
clear all;
tic;
load('eeg_array.mat')
load('chansLables.mat');
%%
tf_all=[];
labels_all= [];
baseline_all= [];
subsess_all= [];
%
for ch = 1:length(chansLables)
    chan = chansLables{ch};
    for ieeg=1:size(eeg_array,2)
    
        EEG= eeg_array{ieeg};
        [tf, frex,wvlt_times, tf_avg, baseline] = wavelet_tf (EEG, chan, 5, 30, 50, [5 15],1,[-2100 -1650],1,[-2100 0],'log', 0);

        labels= extractfield(EEG.event,'type')'; %extracting labels
        labels(1:2:end)= [];
        labels_all= cat(1,labels_all,labels);
        %subsess= repmat([str2num(EEG.subject) str2num(EEG.session)],EEG.trials,1); %to use with old array, when sub and sess are chars
        subsess= repmat([EEG.subject EEG.session],EEG.trials,1); % to use in new eeg_arrays
        subsess_all= cat(1,subsess_all, subsess);

        tf_all= cat(3,tf_all,tf);

        baseline_all= cat(3,baseline_all,baseline); %extracting baseline
        tf_diff{ieeg}= mean(tf(:,:,labels==8),3)-mean(tf(:,:,labels==9),3);


    end
        %%
%% removing outliers from wavelet and placing nan instead
    for iclean= 1:size(frex,2)
        %out= max(squeeze(tf_all(iclean,:,:))) >4;
        %tf_all(iclean,:,out)= nan;
        out= isoutlier(max(squeeze(tf_all(iclean,:,:))));
        tf_all(iclean,:,out)= nan;
        sumout(iclean)= sum(out);
    end
    %%
    good=tf_all(:,:,labels_all==8);
    bad=tf_all(:,:,labels_all==9);
    %%
    ampmax= max(squeeze(tf_all(1,:,:)));
%     figure;
%     
%     plot (wvlt_times,squeeze(tf_all(36,:,:)))


    %%
    figure('Units','normalized','Position',[0.06,0.08,0.9,0.78])
    sgtitle(chan);
    subplot(1,2,1);
    imagesc(wvlt_times,frex,nanmean(tf_all(:,:,labels_all==8),3)-nanmean(tf_all(:,:,labels_all==9),3));
    set(gca, 'CLimMode', 'auto')
    title ('mean diff ALL');
    colorbar();
    %caxis([0.5 3])
    colormap(jet);
    axis xy;

    %plot significance 
    for i=1:50
        for j=1:526
       [~,sig(i,j)]= ttest2(bad(i,j,:),good(i,j,:));    
        end
    end
    sig(sig > 0.02) = NaN;
    sig= 1-sig;

    thing= sig;
    subplot(1,2,2);
    imagesc(thing);
    set(gca, 'CLimMode', 'auto')
    title ('p < .02');
    colorbar();
    colormap(jet);
    axis xy;
end
t = toc;