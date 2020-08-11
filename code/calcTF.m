function [tf_all,freqs,time] = calcTF(minFreq,maxFreq,nFreqs,blFlag,baselineTRange,cutRange,method)
% this function calculate the time frequency matrix

    load('../data/eeg_array.mat')
    load('../data/chansLables.mat');
    tf_all = cell(length(chansLables),1);     %prealocate tf_all

    %loops through all channels and calculate wavlet_tf
    for ichan = 1:length(chansLables)
        chan = chansLables(ichan);
        [tf,freqs,wvlt_times,~,~] = cellfun(@(x) wavelet_tf(x, chan, minFreq, maxFreq, nFreqs,...
            [5 15],blFlag,baselineTRange,1,cutRange,method, 0), eeg_array,'UniformOutput',false);
        tf_all{ichan} = cat(3,tf{1:end});   %each cell is different chan containing tf mat of all trials  
    end
    %changing wvlt_times and frex a vector (all indexes are the same)
    time = wvlt_times{1};
    freqs = freqs{1};
end