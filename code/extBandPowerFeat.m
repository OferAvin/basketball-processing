function [featMat,featNames] = extBandPowerFeat(tf,bandRange, chansLables, freqs, time)
%this function calculates average bandpower for each trial acording to bandRange
%   -tf: time frequency matrix
%   -bandRange: cell array contains the electrode, time range and frequency
%   rnage on which the average power is calculated


    [ch,t,b] = cellfun(@(x) extBPPrmtr(x, chansLables, freqs, time),...
        bandRange,'UniformOutput',false);
    avgPowCell = cellfun(@(x,y,z) mean(mean(tf{x}(y,z,:))),ch,b,t,'UniformOutput',false);
    featMat = (cellfun(@(x) squeeze(x),avgPowCell,'UniformOutput',false));
    featMat = [featMat{:}];
    featNames = cellfun(@(x) {[num2str(x{1}) ' ' num2str(x{3}(1)) ':' num2str(x{3}(2)) 'Hz ' num2str(x{2}(1))...
        ':' num2str(x{2}(2)) 'ms']},bandRange,'UniformOutput',false);
end