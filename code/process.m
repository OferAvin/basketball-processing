close all;
clear all;

load('../data/eeg_array.mat')
load('../data/chansLables.mat');
%% parameters of wavelet TF
minFreq = 5;
maxFreq = 40;
nFreqs = 70;
cutRange = [-2100 0];
baselineTRangeTF = [-2100 -1650];
method = {'abs', 'log'};     %choose between log, log_abs, abs, power
blFlag = [0, 1];         %1-calculate tf with baceline, 0-without bacceline, should corispond to methods order 
plotFlagTF = 0;     %1-plot, 0-do not plot
%% parameters of bandpower
validSize= 190;
minsize= 100;
minIntensity= 0.9935;
%% parameters of ERD\ERS features
baselineERDS=[-2100 -1700];
plotFlagERDS = 0;
%% general parameters
classes2analyze = [8,9];
pVal = 0.025;
%% features parameters
nFeatSelect = 36;
featsToRM = {'A1','A2','Pz'};

balanceTrainSet = 1;
k = 10; %for cross validation

%extracting constants from eeg_array
sRate = eeg_array{1}.srate;             
nTimePointsWvlt = abs(cutRange(1) - cutRange(2))/(1000/sRate)+1;    
trialsPset = cellfun(@(x) extractfield(x,'trials') ,eeg_array, 'UniformOutput',false);
nTrials = sum([trialsPset{:}]);
%extracting lables from all sets of eeg_array
labels_all = cellfun(@(x) extractfield(x.event,'type') ,eeg_array, 'UniformOutput',false);
labels_all = cat(2,labels_all{1:end})';
labels_all(labels_all==2) = [];
%extracting subsess from all sets of eeg_array
subsess_all = cellfun(@(x) repmat([x.subject x.session],x.trials,1), eeg_array,'UniformOutput',false);
subsess_all = cat(1,subsess_all{1:end});

%% calculate tf
for i = 1:length(method)
    tfName = [method{i} '_' num2str(blFlag(i))];
    [tf_all,frex,wvlt_times] = calcTF(minFreq,maxFreq,nFreqs,blFlag(i),baselineTRangeTF,cutRange,method{i});
    tfStruct.(tfName) = tf_all;
end


%% get spectogram features

[spectFeaturesIdx,spectFeaurestNames] = cellfun(@(x,y,z) calcSpecFeat(x,y,...
    validSize,minsize,minIntensity,wvlt_times,frex,labels_all,classes2analyze...
    ,pVal,plotFlagTF),tf_all,chansLables,'UniformOutput',false);

spectFeaurestNames = cat(1,spectFeaurestNames{:})';

% extract the spect features (need for train and for valid sets)
 %%TO DO %%%  [featMat] = extSpecFeat(tf,spectFeaturesIdx);

%% get ERD\ERS features
 [ERDSFeatures,ERDSFeatureNames] = cellfun(@(x,y) computeERD_ERS(x,y,wvlt_times,frex,...
     labels_all,pVal,baselineERDS,plotFlagERDS),tf_all,chansLables,'UniformOutput',false);
 ERDSFeatures= cat(2,ERDSFeatures{:});
 ERDSFeatureNames= cat(2,ERDSFeatureNames{:});
 
%% 
featMat= cat(2,spectFeaturesIdx,ERDSFeatures); %concat between different types of features
featNames = [spectFeaurestNames,ERDSFeatureNames];
[featMat,featNames] = rmByFeatName(featsToRM,featMat,featNames);

%% features selection
[balancedMat,labs] = arangeLables(labels_all,featMat,3,balanceTrainSet);

[selectMat,featIdx,featOrder] = selectFeat(balancedMat,nFeatSelect,lables);

Results = crossValidation(k,selectMat,lables);




