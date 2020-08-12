close all;
clear all;
tic;
load('../data/eeg_array.mat')
load('../data/chansLables.mat');
%%
minFreq = 5;
maxFreq = 40;
nFreqs = 70;
cutRange = [-2100 0];
baselineTRange = [-2100 -1650];
blFlag = 1;     %1-calculate tf with baceline, 0-without bacceline 
method = 'log'; %choose between log, log_abs, abs, power

plotFlag = 0;   %1-plot, 0-do not plot
pVal = 0.02;

nFeatSelect = 20;


%extracting constants from eeg_array
sRate = eeg_array{1}.srate;             
nTimePointsWvlt = abs(cutRange(1) - cutRange(2))/(1000/sRate)+1;    
trialsPset = cellfun(@(x) extractfield(x,'trials') ,eeg_array, 'UniformOutput',false);
totNTrials = sum([trialsPset{:}]);
%extracting lables from all sets of eeg_array
labels_all = cellfun(@(x) extractfield(x.event,'type') ,eeg_array, 'UniformOutput',false);
labels_all = cat(2,labels_all{1:end})';
labels_all(labels_all==2) = [];
%extracting subsess from all sets of eeg_array
subsess_all = cellfun(@(x) repmat([x.subject x.session],x.trials,1), eeg_array,'UniformOutput',false);
subsess_all = cat(1,subsess_all{1:end});

%calculate tf
[tf_all,frex,wvlt_times] = calcTF(minFreq,maxFreq,nFreqs,blFlag,baselineTRange,cutRange,method);

%plot diff and pval for each channel
if plotFlag == 1
    cellfun(@(x,y)  plotDiffandPval(x,y,wvlt_times,frex,labels_all,pVal),tf_all,chansLables);
end



%% get bandpower features

logBandPrmtr = getLogBandPrmtr();
featMat = extBandPower(tf_all,logBandPrmtr,chansLables,frex,wvlt_times);


%% features selection
[featIdx,selectMat,featOrder] = selectFeat(featMat,nFeatSelect,labels_all);
