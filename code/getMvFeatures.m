%function [featMat,featNames] = getMvFeatures (eeg_array,chansLables,tStart,tEnd)
tStart= -1600;
tEnd= 800;
time= eeg_array{1}.times >tStart & eeg_array{1}.times < tEnd;
load chansLables;
%features to compute

% STD of signal
fStd= cellfun(@(x) permute(std(x.data(:,time,:),[],2),[3 1 2]), eeg_array,'UniformOutput',false);
fStd= addNansChans(fStd);
fStd= cat(1,fStd{:});
fStdNames= cellfun (@(x) {[x '_std_mv']}, chansLables,'UniformOutput',false)';

% power spectrum of signal (relative?)

% mean of signal
fMean= cellfun(@(x) permute(mean(x.data(:,time,:),2),[3 1 2]), eeg_array,'UniformOutput',false);
fMean= addNansChans(fMean);
fMean= cat(1,fMean{:});
fMeanNames= cellfun (@(x) {[x '_mean_mv']}, chansLables,'UniformOutput',false)';

% median of signal
fMedian= cellfun(@(x) permute(median(x.data(:,time,:),2),[3 1 2]), eeg_array,'UniformOutput',false);
fMedian= addNansChans(fMedian);
fMedian= cat(1,fMedian{:});
fMedianNames= cellfun (@(x) {[x '_median_mv']}, chansLables,'UniformOutput',false)';

% spectrum enthropy?

% max value of the signal?
fMax= cellfun(@(x) permute(max(x.data(:,time,:),[],2),[3 1 2]), eeg_array,'UniformOutput',false);
fMax= addNansChans(fMax);
fMax= cat(1,fMax{:});
fMaxNames= cellfun (@(x) {[x '_max_mv']}, chansLables,'UniformOutput',false)';

% features from ex5 of matlab course (have files with codes)
%end