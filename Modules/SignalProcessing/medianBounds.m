function medianValue = medianBounds(mask, map, AP, DV, f)
%% Lazy Parameters
if nargin < 3
    AP = [0, 1];
end
if nargin < 4
    DV = [0, 1];
end
if nargin < 5
    f = @nanmedian;
end

%% Extract medians
stats = regionprops(mask, 'Centroid', 'BoundingBox');
if ~any(mask(:)) || all(isnan(mask(:))) || any(isnan(AP)) || any(isnan(DV))
    medianValue = NaN;
    return
end
bb = stats.BoundingBox;

X1 = bb(1) + bb(3) * AP(1);
Y1 = bb(2) + bb(4) * DV(1);

X2 = bb(1) + bb(3) - bb(3) * (1 - AP(2));
Y2 = bb(2) + bb(4) - bb(3) * (1 - DV(2));

map = map(round(Y1):round(Y2), round(X1):round(X2));

medianValue = f(map(:));

end

