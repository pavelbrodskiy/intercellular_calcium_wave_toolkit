% This function takes a cell array of PSDs (n{mxp}, where n=number of samples,
% m=number of bins, and and p=number of frequency bins), and generates
% composites for each sample, then composites for each category.

function [medPSD, ci] = compositeSpectra(cellPSD, category, percentile, compositeSamples)
if nargin < 2
    category = categorical(ones(size(cellPSD)));
end
if nargin < 3
   percentile = [15.865, 84.135]; 
end
if nargin < 4
    compositeSamples = false;
end

if compositeSamples
    for i = length(cellPSD):-1:1
        PSDs = cellPSD{i};
        PSDs = normSpectra(PSDs);
        medPSD(i,:) = ciSpectra(PSDs, percentile);
    end
    
    [medPSD, ci] = ciSpectra(medPSD, percentile);
else
    PSDs = [];
    for i = length(cellPSD):-1:1
        PSDs = [PSDs; cellPSD{i}];
    end
    PSDs = normSpectra(PSDs);
    
    [medPSD, ci] = ciSpectra(PSDs, percentile);
end