% Important parameters: tau (1, 2, 3), minAmplitude, minPeriod, minPeakWidth
% analysisSettings contains: tau1, tau2, tau3, minAmplitude


function [stats, plotData, times] = extractStats(I, analysisSettings, RFP, dF_over_f)
%% Return empty structure if no inputs
if nargin == 0
    stats.mean_RFP = NaN;
    stats.min_I_over_RFP = NaN;
    stats.median_I_over_RFP = NaN;
    stats.mean_I_over_RFP = NaN;
    stats.dfOverF_integrated_one_channel = NaN;
    stats.median_I = NaN;
    stats.AmpRFP = NaN;
    stats.Freq = NaN;
    stats.Period = NaN;
    stats.AmpNormDep = NaN;
    stats.AmpNorm = NaN;
    stats.Amp = NaN;
    stats.Freq = NaN;
    stats.Period = NaN;
    stats.WHM = NaN;
    stats.PeakRate = NaN;
    stats.Integral_by_dutyCycle = NaN;
    stats.DutyCycle = NaN;
    stats.AmpRFP = NaN;

    times = NaN;
    plotData = NaN;
    return
end

%% Define parameters
timestep = 10;
tau = analysisSettings.tau;
type = analysisSettings.dFoverFType;

if nargin < 3
    RFP = nan(size(I));
end

%% Initialization
I = double(I);
findPeaksArgs = {	'SortStr'          , 'descend'                         	, ...
    'widthReference'   , 'halfprom'                       	,...
    'MinPeakProminence', analysisSettings.minAmplitude      ,...
    'MinPeakDistance'  , analysisSettings.minPeriod                 ,...
    'MinPeakWidth'     , analysisSettings.minPeakWidth              };

%% Preprocess signal
RFP(isnan(I)) = [];
I(isnan(I)) = [];
dF_overF1 = dfOverF(I, tau, timestep, type);
dF_overF2 = I ./ RFP;

%% Find peaks in dF/F
[~,peakTimes,peakWHMs,peakAmplitudes] = findpeaks(dF_overF1, 1/timestep, findPeaksArgs{:});

sortmat = [peakTimes(:), peakAmplitudes(:), peakWHMs(:)];

numberOfPeaks = length(peakTimes);
duration = (length(I) - 1) * timestep;
peaksInmHz = 1000 * numberOfPeaks / duration;

%% Extract features from RFP profile
if nargin >= 3
    stats.mean_RFP = mean(RFP);
    stats.min_I_over_RFP = min(dF_overF2);
    stats.median_I_over_RFP = median(dF_overF2);
    stats.mean_I_over_RFP = mean(dF_overF2);
else
    stats.mean_RFP = nan;
    stats.min_I_over_RFP = nan;
    stats.median_I_over_RFP = nan;
    stats.mean_I_over_RFP = nan;
end
stats.dfOverF_integrated_one_channel = mean(dF_overF1);

%% Extract features for each peak
stats.median_I = median(I);

stats.AmpRFP    = NaN;

if numberOfPeaks > 0
    sortedmat = sortrows(sortmat,1);
    
    peakTimes = sortedmat(:, 1)';
    peakNormAmplitudes = sortedmat(:, 2);
    peakWHMs = sortedmat(:, 3)';
    
    periods = peakTimes(2:end) - peakTimes(1:end-1);
    frequencies = 1000 ./ periods;
    peakAmplitudes = I(round(peakTimes/10)) - stats.median_I;
    
    stats.AmpNorm	= median(peakNormAmplitudes);
    stats.AmpNormDep= median(peakAmplitudes ./ stats.median_I);
    stats.Amp       = median(peakAmplitudes);
    stats.WHM       = median(peakWHMs);
    stats.PeakRate  = peaksInmHz;
    stats.Freq      = median(frequencies);
    stats.Period	= median(periods);
    stats.Integral_by_dutyCycle	= sum(1/2 * peakWHMs(:) .* peakAmplitudes(:)) ./ length(dF_overF1);
    stats.DutyCycle = sum(peakWHMs) ./ length(dF_overF1);
    
    if nargin >= 3
        stats.AmpRFP = mean(dF_overF2(round(peakTimes/10)));
    else
        stats.AmpRFP = nan;
    end
end

if numberOfPeaks == 1
    stats.Freq      = 0;
    stats.Period	= 3600;
elseif numberOfPeaks == 0
    stats.AmpNormDep= NaN;
    stats.AmpNorm	= NaN;
    stats.Amp       = NaN;
    stats.Freq      = 0;
    stats.Period	= 3600;
    stats.WHM       = 0;
    stats.PeakRate  = 0;
    stats.Integral_by_dutyCycle  = 0;
    stats.DutyCycle = 0;
    stats.AmpRFP    = NaN;
end

stats.nPeaks = numberOfPeaks;

if nargout > 1
    plotData.findPeaksArgs = findPeaksArgs;
    plotData.dF_overF = dF_overF1;
    if numberOfPeaks > 0
        times = peakTimes;
    else
        times = [];
    end
end

stats.DutyCycle_by_df_over_f = sum(double(dF_overF1 < 0)) / length(dF_overF1);

return


% %% Parameters (lazy)
% if nargin > 2 && overide
%     minAmplitude = settings.overide.minAmplitude; % Normalized
%     timeStep = settings.overide.timeStep; % [s]
%     minPeakWidth = settings.overide.minPeakWidth; % [s]
%     minTime = settings.overide.minTime; % [s]
%     padsize = settings.overide.padsize;
%     windowSize = settings.overide.windowSize;
%     minFilt = settings.overide.minFilt;
%     maxFilt = settings.overide.maxFilt;
% else
%     minAmplitude = 89.6; %100; % Normalized
%     timeStep = 10; % [s]
%     minPeakWidth = 35.1; %0; % [s]
%     minTime = 53; %6; % [s]
%     padsize = 67; %50;
%     windowSize = 38; %50;
%     minFilt = 1.16; %1.3;
%     maxFilt = 38.7; %15;
% end
%
% findPeaksArgs = {'SortStr'          , 'descend', ...
%     'widthReference'   , 'halfprom',...
%     'MinPeakProminence'  , minAmplitude,...
%     'MinPeakDistance'  , minTime / timeStep,...
%     'MinPeakWidth'     , minPeakWidth / timeStep};
%
% % if ndims(video) == 3
% %     I = squeeze(mean(mean(video,1),2));
% % else
% %     I = video';
% % end
%
% % t = (0:(length(I)-1))*timeStep;
%
% %% Use PSD method to get major frequencies
% % [PSD, freqList, domFreq, relPower] = spectralDensityEstimate(I', t);
% % raw.domFreq = domFreq * 1000;
% % raw.PSD = PSD;
% % raw.freqList = freqList * 1000;
% % raw.relPower = relPower;
% % switch length(domFreq)
% %     case 0
% %         stats.PSD_maxFreq = 0;
% %         stats.PSD_maxPower = NaN;
% %         stats.PSD_powerDifference = 0;
% %     case 1
% %         stats.PSD_maxFreq = domFreq(1) * 1000;
% %         stats.PSD_maxPower = relPower(1);
% %         stats.PSD_powerDifference = relPower(1);
% %     otherwise
% %         stats.PSD_maxFreq = domFreq(1) * 1000;
% %         stats.PSD_maxPower = relPower(1);
% %         stats.PSD_powerDifference = relPower(2) - relPower(1);
% % end
% % stats.PSD_numFreq = length(domFreq);
%
% %% Rescale signal
%
% rescaledI = I - min(I);
% intensityScale = max(rescaledI);
% rescaledI = rescaledI / intensityScale;
%
% %% Lowpass filtering
% % Fs = 1/6;                    % sample rate in Hz
% % x = rescaledI; % noisy waveform
% %
% % Fnorm = cutoffFreq/(Fs/2);           % Normalized frequency
% % df = designfilt('lowpassfir','FilterOrder',filterOrder,'CutoffFrequency',Fnorm);
% % D = mean(grpdelay(df)); % filter delay in samples
% % y = filter(df,[x; zeros(D,1)]); % Append D zeros to the input data
% % y = y(D+1:end);                  % Shift data to compensate for delay
%
% %% Noise reduction
% % t = linspace(0,60*length(I)/(60*timeStep + 1),length(I));
% % smoothNormalized = rescaledI;
% % % b = (1/windowSize)*ones(1,windowSize);
% % % a = 1;
% % % smoothNormalized = filter(b,a,rescaledI);
% % y = filter(b,a,I);
% IPad = [repmat(I(1), [padsize, 1]); I; repmat(I(end), [padsize, 1])];
% if minFilt == 0
%     filt1A = IPad;
% else
%     filt1A = imgaussfilt(IPad,minFilt);
% end
%
% % if minFilt > 700
% %     filt2A = IPad;
% % else
% filt2A = imgaussfilt(IPad,maxFilt);
% % end
%
% smoothNormalized = filt1A - filt2A;
% smoothNormalized = smoothNormalized((padsize+1):(end-(padsize+1)));
%
% %% Get minimum projection
%
% originalSignal = [repmat(I(1), [padsize, 1]); I; repmat(I(end), [padsize, 1])];
% hank = hankel(originalSignal);
% h3 = hank(:,1:windowSize);
% dilatedSignal = min(h3, [], 2);
%
% originalSignal = flipud([repmat(I(1), [padsize, 1]); I; repmat(I(end), [padsize, 1])]);
% hank = hankel(originalSignal);
% h3 = hank(:,1:windowSize);
% dilatedSignal2 = min(h3, [], 2);
%
% dilatedSignal = min([dilatedSignal, flipud(dilatedSignal2)], [], 2);
%
% dilatedSignal = dilatedSignal((padsize+1):(end-padsize));
%
% if isempty(dilatedSignal)
%     dilatedSignal = I;
% end
%
% %% Get peak locations
% [~,locs,w,p] = findpeaks(smoothNormalized, findPeaksArgs{:});
%
% % UnNormalize
% % val = val + mean(imgaussfilt(IPad,10));
%
% sortmat = [locs'; p'; w']';
% sortedmat = sortrows(sortmat,1);
%
% %% Extract features for each peak
% if length(p) >= 3
%     times = sortedmat(:,1) * timeStep; % [s]
%     amplitudes = sortedmat(:,2); % [a.u.]
%     WHM = sortedmat(:,3) * timeStep; % [s]
%
%     % end and start times aproximate that peak WHM is bisected by peak location
%     endTimes = times + WHM / 2; % [s]
%     startTimes = times - WHM / 2; % [s]
%
%     refractoryPeriods = startTimes(2:end) - endTimes(1:end-1); % [s]
%
%     periods = times(2:end) - times(1:end-1); % [s]
%     localPeriods = (periods(2:end) + periods(1:end-1)) / 2; % [s]
%     frequencies = 1000 ./ periods;  % [mHz]
%     dutyCycles = WHM(2:end-1) ./ localPeriods; % [ ]
% else
%     endTimes = NaN; % [s]
%     startTimes = NaN; % [s]
%     times = [];
%     amplitudes = 0;
%     WHM = 0;
%     periods = 360; % [s]
%     frequencies = 0;  % [1/s]
%     localPeriods = 360;%NaN;
%     dutyCycles = 0;
%     refractoryPeriods = 360;%NaN;
% end
%
%
% %% Pack up raw data
% raw.times = times;
% raw.amplitudes = amplitudes;
% raw.WHM = WHM;
% raw.endTimes = endTimes;
% raw.startTimes = startTimes;
% raw.refractoryPeriods = refractoryPeriods;
% raw.periods = periods;
% raw.basal = max([ones(size(locs)), dilatedSignal(locs)],[],2);
% raw.peak = raw.basal + p;
% raw.frequencies = frequencies;
% raw.normAmplitudes = 100 * amplitudes ./ raw.basal;
% raw.localPeriods = localPeriods;
% raw.dutyCycles = 100 * dutyCycles;
% raw.halfWHMtimesAmp = raw.amplitudes .* WHM / 2;
% raw.halfWHMtimesAmpNorm = raw.normAmplitudes .* WHM / 2;
%
% %% Combine features for all peaks
% stats.peakNumber = length(p); % [ ]
% stats.refractoryPeriod = min(refractoryPeriods);
% stats.signalMedian = median(I);
%
%
% features =  fieldnames(raw);
%
% for i = 1:length(features)
%     stats.(['mean' features{i}]) = mean(raw.(features{i}));
%     stats.(['med' features{i}]) = median(raw.(features{i}));
%     stats.(['std' features{i}]) = std(raw.(features{i}));
%     stats.(['prctstd' features{i}]) = 100 * std(raw.(features{i})) ./ mean(raw.(features{i}));
% end
%
% % stats.PSD = {PSD};
%
% plotOut = [{smoothNormalized}, findPeaksArgs];



