function[ERDS,bandNames] = computeERDS(tf,wvlt_times,frex,baseline)
% this function get a tf matrix and baseline period, and return ERDS
% matrix, wich the rows are bands (and not frex anymore), and return
% bandNames

%baseline= [-2100 -1700]; % the baseling that will serve a refference to ERD\ ERS
bands= {[5 7.5] [7.5 13] [13 20] [20 30] [30 40]}; %theta, alpha, lower beta, upper beta, gamma
bandNames= {'theta', 'alpha','low beta','high beta', 'gamma'};
blTimes= baseline(1)<= wvlt_times & wvlt_times <= baseline(2);

%% squeeze tf into bands: tf_band
tf_band= nan(size(bands,2),size(tf,2),size(tf,3));
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
ERDS= nan(size(tf_band,1),size(tf_band,2),size(tf_band,3));
for iband=1: size(tf_band,1)
    refTime= nanmean(tf_band(iband,blTimes,:),2);

    ERDS(iband,:,:)= tf_band(iband,:,:) ./ refTime;
end






end