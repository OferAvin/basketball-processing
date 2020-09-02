%close all;
%clear all;
%%
%load('../data/eeg_array.mat');
load('../data/chansLables.mat');
[labels_all,metaData,nTrials,sRate] = get_eeg_array_constants (eeg_array); % get labels subess srate and total N trials
%% parameters of wavelet TF
minFreq = 5;
maxFreq = 40;
nFreqs = (maxFreq-minFreq)*2; 
cutRange = [-2100 0];
baselineTRangeTF = [-2100 -1650];
method = {'abs', 'log'};     %choose between log, log_abs, abs, power
blFlag = [0, 1];         %1-calculate tf with baceline, 0-without bacceline, should corispond to methods order 
plotFlagTF = 1;     %1-plot, 0-do not plot
nTimePointsWvlt = abs(cutRange(1) - cutRange(2))/(1000/sRate)+1;  
ntf = length(method);
%% parameters of spectogram features
validSize= 160;
minsize= 100;
minIntensity= 0.988;
%% parameters of ERD\ERS features
baselineERDS=[-2100 -1700];
plotFlagERDS = 1;
%% general parameters
classes2analyze = [8,9];
pVal = 0.0285;
%% features parameters
nFeatSelect = 62;
featsToRM = {'A1','A2','Pz'};
balanceTrainSet = 1;
nFold = 8; %for cross validation

%% initilize classify constants
nclass = 2;
cmT = zeros(nclass,nclass);  % allocate space for confusion matrix
results = cell(nFold,1);
trainErr = cell(nFold,1);
acc = zeros(nFold,1);
%% allocating tfStruct
tfStruct(1:ntf) = struct('tf_all',[],'method',[],'blFlag',[],'ERDS',[],...
    'tfTrain',[],'tfVal',[],'ERDSVal',[],'ERDSTrain',[],'SpectFeatMatTrain',[],...
    'SpectFeatMatVal',[],'SpectFeaurestNames',[],'SpectFeaturesIdx',[],...
    'ERDSFeatMatTrain',[],'ERDSFeatMatVal',[],'ERDSFeatNames',[]);
%% calculate tf

for itf = 1:ntf
    [tf_all,frex,wvlt_times] = calcTF(eeg_array,chansLables,minFreq,maxFreq,nFreqs,blFlag(itf),baselineTRangeTF,cutRange,method{itf});
    tfStruct(itf).tf_all = tf_all;
    tfStruct(itf).method = method{itf};
    tfStruct(itf).blFlag = blFlag(itf);
end

%% calculate ERD/ERS
for itf = 1:ntf
    [tfStruct(itf).ERDS,bandNames] = cellfun(@(x) computeERDS(x,wvlt_times,frex,baselineERDS),tfStruct(itf).tf_all,'UniformOutput',false);
end
bandNames = bandNames{1};

%% the new arrange tf
for itf = 1:ntf
tfStruct(itf).tf_all= cellfun(@(x) remove_trials_from_tf(x,metaData(:,4)==3) , tfStruct(itf).tf_all,'UniformOutput',false); %remove '3'
tfStruct(itf).ERDS= cellfun(@(x) remove_trials_from_tf(x,metaData(:,4)==3) , tfStruct(itf).ERDS,'UniformOutput',false);
end
metaData(metaData(:,4)==3,:)=[]; % remove '3' from metaData

rmIdx = balancePerSetTf (metaData); %logical '1' means that trial is designated for removal
for itf = 1:ntf %balance
tfStruct(itf).tf_all= cellfun(@(x) remove_trials_from_tf(x,rmIdx) , tfStruct(itf).tf_all,'UniformOutput',false); 
tfStruct(itf).ERDS = cellfun(@(x) remove_trials_from_tf(x,rmIdx) , tfStruct(itf).ERDS,'UniformOutput',false);
end
metaData(rmIdx,:)=[]; % balance metaData


%% k folds 
idxSegments = mod(randperm(size(metaData,1)),nFold)+1;   %randomly split trails in to k groups
for k = 1:nFold
    
for itf = 1:ntf
        % each test on 1 group and train on the else
        validSet = logical(idxSegments == k)';
        trainSet = logical(idxSegments ~= k)';
        tfStruct(itf).tfVal = [];
        tfStruct(itf).tfTrain = [];
        tfStruct(itf).ERDSVal = [];
        tfStruct(itf).ERDSTrain = [];

        tfStruct(itf).tfVal = cellfun(@(x) x(:,:,validSet),tfStruct(itf).tf_all,'UniformOutput',false);
        tfStruct(itf).tfTrain = cellfun(@(x) x(:,:,trainSet),tfStruct(itf).tf_all,'UniformOutput',false);
        tfStruct(itf).ERDSVal = cellfun(@(x) x(:,:,validSet),tfStruct(itf).ERDS,'UniformOutput',false);
        tfStruct(itf).ERDSTrain = cellfun(@(x) x(:,:,trainSet),tfStruct(itf).ERDS,'UniformOutput',false);

% get spectogram features

[tfStruct(itf).SpectFeatMatTrain,tfStruct(itf).SpectFeatMatVal,...
    tfStruct(itf).SpectFeaurestNames,tfStruct(itf).SpectFeaturesIdx] =...
    getAutoSpecFeat(tfStruct(itf).tfTrain,tfStruct(itf).tfVal,chansLables, validSize,minsize,...
    minIntensity,wvlt_times,frex,labels_all(trainSet),classes2analyze,pVal,plotFlagTF);

% get ERD\ERS features
 [tfStruct(itf).ERDSFeatMatTrain,tfStruct(itf).ERDSFeatMatVal,tfStruct(itf).ERDSFeatNames] =...
     getAutoERDSFeat(tfStruct(itf).ERDSTrain,tfStruct(itf).ERDSVal,...
     chansLables,labels_all(trainSet),wvlt_times,bandNames,pVal,plotFlagERDS);
 end
%
TrainFeatMat= cat(2,tfStruct(:).SpectFeatMatTrain,tfStruct(:).ERDSFeatMatTrain); %concat between different types of features TRAIN
ValFeatMat= cat(2,tfStruct(:).SpectFeatMatVal,tfStruct(:).ERDSFeatMatVal); %concat between different types of features VALIDATION
featNames{k} = [tfStruct(:).SpectFeaurestNames,tfStruct(:).ERDSFeatNames];

[TrainFeatMat,ValFeatMat,featNames{k}] = rmByFeatName(featsToRM,TrainFeatMat,ValFeatMat,featNames{k});

% features selection
%[balancedMatTrain,labelsTrain,metaDataTrain] = arangeLabelsForFeatMat(metaData(trainSet,:),TrainFeatMat,3,balanceTrainSet); %arrange train
%[ValFeatMat,labelsVal,metaDataTest] = arangeLabelsForFeatMat(metaData(validSet,:),ValFeatMat,3,0); %arrange validation
%these 2 lines are instead the arrange. i put the tf arrange in row 
labelsTrain= metaData(trainSet,4); balancedMatTrain= TrainFeatMat;
labelsVal= metaData(validSet,4); ValFeatMat=ValFeatMat;
%

[selectMatTrain,featIdx,featOrder{k}] = selectFeat(balancedMatTrain,nFeatSelect,labelsTrain);
selectMatVal= ValFeatMat(:,featIdx); %keeping in valSet only the N best features
% classify and save results
[results{k},trainErr{k}] =...
            classify(selectMatVal,selectMatTrain,labelsTrain,'linear');
        acc(k) = sum(results{k} == labelsVal);  %sum num of correct results
        acc(k) = acc(k)/length(results{k})*100;             
        %build the confusion matrix
        cm = confusionmat(labelsVal,results{k});
       cmT =cmT + cm;
       
end
%calculate accuracy and f1
    percision = cmT(1,1)/(cmT(1,1) + cmT(1,2));
    recall = cmT(1,1)/(cmT(1,1) + cmT(2,1));
    f1 = 2*((percision*recall)/(percision+recall));
   
    accAvg = mean(acc);
    accSD = std(acc);
        
    trainAcc = (1-cell2mat(trainErr))*100;
    trAccAvg = mean(trainAcc);
    trAccSD = std(trainAcc);
    
    Results = struct('nFolds',nFold,'acc',accAvg,'SD',accSD,'trainAcc',trAccAvg,'trainSD',trAccSD,...
        'f1',f1,'percision',percision,'recall',recall,'conf_mat',cmT);
%%
for i=1:nFold
topFeatNames(1:size(featNames{i},2),i)= featNames{i}(featOrder{i})';
end
%Results = crossValidation(k,selectMatTrain,lables); %to be changed and build an bew function
