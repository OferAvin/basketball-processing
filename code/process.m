close all;
clear all;
tic;
load('../data/eeg_array.mat')
load('../data/chansLables.mat');
%% parameters of wavelet TF
minFreq = 5;
maxFreq = 40;
nFreqs = 70;
cutRange = [-2100 0];
baselineTRangeTF = [-2100 -1650];
blFlag = 0;     %1-calculate tf with baceline, 0-without bacceline 
method = 'abs'; %choose between log, log_abs, abs, power
plotFlagTF = 0;   %1-plot, 0-do not plot
%% parameters of ERD\ERS features
baselineERDS=[-2100 -1700];
plotFlagERDS = 0;
%% general parameters
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

%% calculate tf
[tf_all,frex,wvlt_times] = calcTF(minFreq,maxFreq,nFreqs,blFlag,baselineTRangeTF,cutRange,method);

%%plot diff and pval for each channel
if plotFlagTF == 1
    cellfun(@(x,y)  plotDiffandPval(x,y,wvlt_times,frex,labels_all,pVal),tf_all,chansLables);
end



%% get bandpower features

logBandPrmtr = getLogBandPrmtr();
bandPowFeatures = extBandPower(tf_all,logBandPrmtr,chansLables,frex,wvlt_times);


%% get ERD\ERS features
 [ERDSFeatures,ERDSFeatureNames] = cellfun(@(x,y) computeERD_ERS(x,y,wvlt_times,frex,...
     labels_all,pVal,baselineERDS,plotFlagERDS),tf_all,chansLables,'UniformOutput',false);
 ERDSFeatures(ismember(chansLables, 'A1'))= []; %can be run only one time. remove A1 features
 ERDSFeatureNames(ismember(chansLables, 'A1'))= []; %can be run only one time. remove A1 features
 ERDSFeatures(ismember(chansLables, 'A2'))= []; %can be run only one time. remove A2 features
 ERDSFeatureNames(ismember(chansLables, 'A2'))= []; %can be run only one time. remove A2 features
 ERDSFeatures= cat(2,ERDSFeatures{:});
 ERDSFeatureNames= cat(2,ERDSFeatureNames{:});
 
 
%% features selection
featMat= cat(2,bandPowFeatures,ERDSFeatures); %concat between different types of features

[featIdx,selectMat,featOrder] = selectFeat(featMat,nFeatSelect,labels_all);
