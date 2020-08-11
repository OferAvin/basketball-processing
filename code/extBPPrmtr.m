function [chanIdx,timeIdx,bandIdx] = extBPPrmtr(bandPrmtr, chansLables, freqs, time)
%this function extract bandpower time and frequency range parameters 
        chanIdx = find(strcmp(chansLables,bandPrmtr{1}));
        [~,timeMinIdx] = min(abs(time-bandPrmtr{2}(1))); 
        [~,timeMaxIdx] = min(abs(time-bandPrmtr{2}(2)));  
        timeIdx = timeMinIdx:timeMaxIdx;
        [~,bandMinIdx] = min(abs(freqs-bandPrmtr{3}(1)));
        [~,bandMaxIdx] = min(abs(freqs-bandPrmtr{3}(2)));
        bandIdx = bandMinIdx:bandMaxIdx;
end