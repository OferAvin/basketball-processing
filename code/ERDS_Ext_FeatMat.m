function [FeatMat] = ERDS_Ext_FeatMat(ERDS,StartEndIdx)
% this function gets ERDS and Start & END indexes, and extract the features
% from ERDS.
FeatMat=[];
c=1;
for iband=1: size(StartEndIdx,2)
    for ifeat=1: size(StartEndIdx{iband},1)
       FeatMat(:,c)= mean(ERDS(iband,StartEndIdx{iband}(ifeat,1):StartEndIdx{iband}(ifeat,2),:),2); %maybe median?
          c= c+1;
    end
end