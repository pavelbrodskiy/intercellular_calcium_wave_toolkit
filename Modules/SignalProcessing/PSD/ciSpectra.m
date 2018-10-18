function [medPSD, ci] = ciSpectra(PSDs, percentile)

if nargin < 2
    percentile = [15.865, 84.135];
end

medPSD = median(PSDs, 1);
ci =  repmat(medPSD, [length(percentile), 1]) - prctile(PSDs,percentile);
ci(1,:) = -ci(1,:);

end

