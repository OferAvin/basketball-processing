function [labels_all,metaData,nTrials,sRate] = get_eeg_array_constants (eeg_array)

%extracting constants from eeg_array
sRate = eeg_array{1}.srate;             
trialsPset = cellfun(@(x) extractfield(x,'trials') ,eeg_array, 'UniformOutput',false);
nTrials = sum([trialsPset{:}]);
%extracting lables from all sets of eeg_array
labels_all = cellfun(@(x) extractfield(x.event,'type') ,eeg_array, 'UniformOutput',false);
labels_all = cat(2,labels_all{1:end})';
labels_all(labels_all==2) = [];
%extracting subsess from all sets of eeg_array
subsess_all = cellfun(@(x) repmat([x.subject x.session],x.trials,1), eeg_array,'UniformOutput',false);
subsess_all = cat(1,subsess_all{1:end});
%%
%extracting lables from all sets of eeg_array
serialNum = cellfun(@(x) extractfield(x.event,'SR') ,eeg_array, 'UniformOutput',false);
serialNum = cat(2,serialNum{1:end})';
serialNum(serialNum==0) = [];

metaData= cat (2,subsess_all,serialNum,labels_all);
end
