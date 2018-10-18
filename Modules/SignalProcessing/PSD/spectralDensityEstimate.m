% Obtain frequencies from signal by PSD analysis. Adapted from: Uhlén, Per.
% "Spectral analysis of calcium oscillations." Sci STKE 2004.258 (2004): 
% pl15.

% BROKEN ON JULY 30th, NO IDEA WHY

function [PSD, freq, domFreq, relPower, power] = spectralDensityEstimate(signal, t)
%% Lazy declaration
degree = 2;
N = 2048;
doHanning = true;
doCentering = true;
minPower = 5;
minOutputs = 2;

%% Initialization
dt = t(2) - t(1);

%% Subtract trend component
if doCentering
    trend = polyfit(t,signal,degree);
    signal = signal - polyval(trend,t);
end

%% Hanning filter
if doHanning
    hanning = 0.5 - 0.5*cos(2*pi*t/t(end));
    signal = signal.*hanning;
end

%% Obtain PSD
G = fft(signal,N);
PSD = G.*conj(G)/N;
PSD = PSD(1:N/2 + 1);
PSD(2:N/2) = 2*PSD(2:N/2);
fs = 1/dt;
freq = fs*(0:N/2)/N;

%% Identify major frequency components
dP = gradient(PSD);
peakIndex = find(dP(1:end-1)>0 & dP(2:end)<0);
peaks = [freq(peakIndex); PSD(peakIndex)]';
peaks = sortrows(peaks,2);

if size(peaks, 1) < 2
    PSD = NaN;
    freq = NaN;
    domFreq = NaN;
    relPower = NaN;
    power = NaN;
    
    return
end

valleyIndex = unique([1, find(dP(1:end-1)<0 & dP(2:end)>0) length(dP)]);
areaP = trapz(freq,PSD);
for x = 1:length(peaks)
    [~,sortedValleys] = sort(abs(freq(valleyIndex)-peaks(x,1)));
    f1 = min(valleyIndex(sortedValleys(1:2)));
    f2 = max(valleyIndex(sortedValleys(1:2)));
    peaks(x,3) = 100*trapz(freq(f1:f2),PSD(f1:f2))/areaP;
end

%% Return values
if isempty(peaks)
    domFreq = inf; % in Hz
 	relPower = 0;
 	power = 0;
else
    sortedPeaks = sortrows(peaks,-3);
    
    if nargout > 2
        returnNumber = max([minOutputs sum(sortedPeaks(:,3) > minPower)]);
        
        domFreq = sortedPeaks(1:returnNumber,1); % in Hz
        relPower = sortedPeaks(1:returnNumber,3);
        power = sortedPeaks(1:returnNumber,2);
    end
end



