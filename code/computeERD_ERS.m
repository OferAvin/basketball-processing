function [features,featureNames] = computeERD_ERS(tf,chan,wvlt_times,frex,labels_all,pVal,baseline,plotFlag)
%%ERD ERS: to run on abs or power only without baseline.
% this function compute relative power ERD ERS.
% the function gets a specific tf for a specific channel.
% the data is devided into bands and the computition is seperate for each
% band.
% the function can plot the results (when plotFlag==1)
% the function returns features and features names: mean values of ERD\ERS
% under bands and times where diff between two classes was more significant
% then pVal.

%baseline= [-2100 -1700]; % the baseling that will serve a refference to ERD\ ERS
bands= {[5 7.5] [7.5 13] [13 20] [20 30] [30 40]}; %theta, alpha, lower beta, upper beta, gamma
bandNames= {'theta', 'alpha','low beta','high beta', 'gamma'};
blTimes= baseline(1)<= wvlt_times & wvlt_times <= baseline(2);

%% squeeze tf into bands: tf_band
for iband=1: size (bands,2) % create tf_band
    Findx= bands{iband}(1)<= frex & frex <= bands{iband}(2);
    tf_band(iband,:,:)= nansum(tf(Findx,:,:));
end
%% compute rel pow of tf_band
for i=1:size(tf_band,2)
    % rel pow
    tf_band(:,i,:)= tf_band(:,i,:) ./ nansum(tf_band(:,i,:));
end
%% compute ERD\S relative to refference time: ERDS
for iband=1: size(tf_band,1)
    refTime= nanmean(tf_band(iband,blTimes,:),2);

    ERDS(iband,:,:)= tf_band(iband,:,:) ./ refTime;
    %ERDS (iband,:,:)= permute(squeeze(mean(tf(Findx,:,:)))' ./ refTime, [3 2 1]);
end

%% compute significant of bands through time
sig=[];
for j=1:size(ERDS,2) %check significant
    for i=1:size(ERDS,1)   
         [~,sig(i,j)] = ttest2 (ERDS(i,j,labels_all==8),ERDS(i,j,labels_all==9));
    end
end
sig= sig < pVal;

%% extract features
features=[];
featureNames={};
StartEndIdx=sig_windows_ERDS(sig,10);
c=1;
for iband=1: size(StartEndIdx,2)
    for ifeat=1: size(StartEndIdx{iband},1)
       features(:,c)= mean(ERDS(iband,StartEndIdx{iband}(ifeat,1):StartEndIdx{iband}(ifeat,2),:),2); %maybe median?
       featureNames(c)= {[chan '_' bandNames{iband} '_'...
           num2str(wvlt_times(StartEndIdx{iband}(ifeat,1))) ':' num2str(wvlt_times(StartEndIdx{iband}(ifeat,2)))]};
       c= c+1;
    end
end
 
%% plot 
if plotFlag==1
figure('Units','normalized','Position',[0.06,0.08,0.9,0.78]);
suptitle(chan); %   sgtitle(chan);
for i=1: size(bands,2)
subplot(size(bands,2),1,i)
plot(wvlt_times, nanmean(ERDS(i,:,labels_all==8),3))
hold on
plot(wvlt_times, nanmean(ERDS(i,:,labels_all==9),3))

plot(wvlt_times,ones(1,length(wvlt_times)),'-*','color','black','MarkerIndices',find(sig(i,:)),...
    'MarkerFaceColor','red',...
    'MarkerSize',10)

xlim ([wvlt_times(1) wvlt_times(end)])
title (bandNames{i});
legend ('good','bad');
end
end
end
