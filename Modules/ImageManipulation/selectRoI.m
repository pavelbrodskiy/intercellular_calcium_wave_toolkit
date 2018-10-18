function [mask, annotation] = selectRoI(annotation, hImage)
if nargin < 2
    close all
    hImage = figure(1);
end

%% Initialize GUI
% hText.String = 'Select whole disc on right figure';
figure(hImage)
imshow(annotation,'InitialMagnification', 200);

%% Select and mark compartment boundary
[~, xDisc, yDisc] = roipoly();
polyCoord((1:length(xDisc))*2-1) = xDisc;
polyCoord((1:length(xDisc))*2) = yDisc;
annotation = insertShape(annotation,'polygon',polyCoord,'LineWidth',2,'Color','red');
imshow(annotation);

%% Make mask
[m, n, ~] = size(annotation);
mask = poly2mask(xDisc, yDisc, m, n);
mask = smoothRoI(mask);
mask = mask(1:m, 1:n);

%% Export user inputs if requested
% etc.Points = polyCoord;

end