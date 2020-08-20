function[StartEndIdx,featureNames] = ERDS_ExtFeat_Idx_Names_Plots(ERDS,chan,wvlt_times,labels_all,pVal,bandNames,plotFlag)
%this function takes ERDS of a specific channel, and returnes the start and
%end Idx of the chosen features for each band. each cell in StartEndIdx is
%corresponding to a band. the function also retutrns feature Names.
% the function returns features names: mean values of ERD\ERS
% under bands and times where diff between two classes was more significant
% then pVal.

% compute significant of bands through time
sig=nan(size(ERDS,1),size(ERDS,2));
for j=1:size(ERDS,2) %check significant
    for i=1:size(ERDS,1)   
         [~,sig(i,j)] = ttest2 (ERDS(i,j,labels_all==8),ERDS(i,j,labels_all==9));
    end
end
sig= sig < pVal;
StartEndIdx=sig_windows_ERDS(sig,14);

featureNames={};
c=1;
for iband=1: size(StartEndIdx,2)
    for ifeat=1: size(StartEndIdx{iband},1)
       featureNames{c}= {[chan '_' bandNames{iband} '_'...
           num2str(wvlt_times(StartEndIdx{iband}(ifeat,1))) ':' num2str(wvlt_times(StartEndIdx{iband}(ifeat,2)))]};
       c= c+1;
    end
end
%% plot 
if plotFlag==1
figure('Units','normalized','Position',[0.06,0.08,0.9,0.78]);
suptitle(chan); %   sgtitle(chan);
for i=1: size(bandNames,2)
subplot(size(bandNames,2),1,i)
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