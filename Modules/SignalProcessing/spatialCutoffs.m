function spatialCutoff = spatialCutoffs(axesMat, maskMat, settings, strip)
if nargin < 4
    strip = false;
end

for i = 1:length(axesMat)
    tmp = axesMat{i};
    cutoffs(i) = mean(tmp(1,:) / size(maskMat{i}, 2));
end

if strip
    spatialCutoff = [zeros(size(cutoffs)); (cutoffs-settings.stripWidth); cutoffs; ones(size(cutoffs))]';
else
    spatialCutoff = [zeros(size(cutoffs)); cutoffs; ones(size(cutoffs))]';
end

end

