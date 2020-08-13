function [tf, frex,wvlt_times, tf_avg, baseline] = wavelet_tf (EEG, chan, min_freq, max_freq, num_frex, range_cycles,bl_flag,bl_limits,cut_edge_flag,cut_edge_limits,transformation, plot)
%current: the plotting is becibel. not abs. not power.

% this function cumputes the wavelet tf analysis. the code is taken from
% mike x cohen ("convolution_with_many_trials_5.m", in the m&m drive)
% with my own adjusments.
% input: EEG, chan, min_freq, max_freq, num_frex, range_cycles,
% bl_flag,bl_limits,cut_edge_flag,cut_edge_limits,transformation('log','abs','log_abs', 'power'), plot(1/0) 
% output:
% tf:power matrix. 1dim is frex, 2dim is time, 3dim is trials, index is power.
% frex : the vector of frequencies
% wvlt_times: the new times vector after edges cutting
% tf_avg: matrix of average power over trials
%bsaline: basline vector for each trial
% ** vector of time is EEG.times
%do be continue- fase extraction

% frequency parameters
% min_freq =  2;
% max_freq = 30;
% num_frex = 40;
frex = linspace(min_freq,max_freq,num_frex);

% which channel to plot
channel2use = chan;

% other wavelet parameters
%range_cycles = [ 4 10 ];

s = logspace(log10(range_cycles(1)),log10(range_cycles(end)),num_frex) ./ (2*pi*frex);
wavtime = -2:1/EEG.srate:2;
half_wave = (length(wavtime)-1)/2;

%% now let's try it again using trial concatenation
% FFT parameters
nWave = length(wavtime);
nData = EEG.pnts * EEG.trials; % This line is different from above!!
nConv = nWave + nData - 1;

% initialize output time-frequency data
tf_avg = zeros(length(frex),EEG.pnts);
tf= zeros (length(frex),EEG.pnts,EEG.trials);

% now compute the FFT of all trials concatenated
alldata = reshape( EEG.data(strcmpi(channel2use,{EEG.chanlocs.labels}),:,:) ,1,[]);
dataX   = fft( alldata ,nConv );


% loop over frequencies
for fi=1:length(frex)
    
    % create wavelet and get its FFT
    % the wavelet doesn't change on each trial...
    wavelet  = exp(2*1i*pi*frex(fi).*wavtime) .* exp(-wavtime.^2./(2*s(fi)^2));
    waveletX = fft(wavelet,nConv);
    waveletX = waveletX ./ max(waveletX);
    
    % now run convolution in one step
    as = ifft(waveletX .* dataX);
    as = as(half_wave+1:end-half_wave);
    
    % and reshape back to time X trials
    as = reshape( as, EEG.pnts, EEG.trials );
    switch transformation %compute power either log, log_abs, abs amplitude, or power
        case {'abs' , 'log_abs'}
            tf(fi,:,:)= permute(abs(as),[3 1 2]); % abs!!!
        case {'log', 'power'}
            tf(fi,:,:)= permute(abs(as).^2 ,[3 1 2]); %.^2 %% power!!!
    end

end
switch transformation %to do log or not
    case {'log', 'log_abs'}
    tf= 10*log10(tf); %%%%  transforming to decibel
end
if sum(sum(sum(tf)))==0 % if channel doex not exsist put nan
    tf(:,:,:)= nan;
end

%% baseline removal
baseline=[];
if bl_flag==1
           % start_bl= find (EEG.times==bl_limits(1));
            %end_bl  = find (EEG.times==bl_limits(2));
            [~,start_bl]=min(abs(EEG.times - bl_limits(1)));
            [~,end_bl]=min(abs(EEG.times - bl_limits(2)));

   baseline= mean(tf(:,start_bl:end_bl,:),2);
   switch transformation
       case {'log', 'log_abs'}
            tf= tf - baseline; %%% if log then minus (-)
       case {'abs','power'}
            tf= tf ./ baseline; %%% if natural then ./
   end

end

%% cut edges
if cut_edge_flag ==1
            low_edge= find (EEG.times==cut_edge_limits(1));
            high_edge  = find (EEG.times==cut_edge_limits(2));
   tf= tf(:,low_edge:high_edge,:);
   wvlt_times= EEG.times (low_edge:high_edge);
else
   wvlt_times= EEG.times;
end
%% compute tf_avg
    % compute power and average over trials
    tf_avg= mean( tf ,3);

%% plotting
    if plot==1
       figure;
    imagesc(wvlt_times,frex,tf_avg);
    set(gca, 'CLimMode', 'auto')
    title (['mean power over trials sub ' EEG.subject ' ses: ' EEG.session]);
    colorbar();
    colormap(jet);
        axis xy;
    end
end