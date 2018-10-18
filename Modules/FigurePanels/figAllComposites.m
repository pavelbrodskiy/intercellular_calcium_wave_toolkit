% This function makes a figure panel for control data with discs falling
% into different size bins.

function metadata = figAllComposites(structMaps, settings, category)
%% Parse Inputs (Lazy)
fieldNames = settings.fieldNames;
mapOrder = settings.mapOrder;
scaleBar = 50;

%% Initialization
structMapsReduced = reduceStructFields(structMaps, fieldNames);
scaleBarPixels = round(scaleBar / settings.scale.x20);

%% Median projections of controls by category
[medianStruct, n, conditions] = medianProjectSpatialMaps(structMapsReduced, category');
coordinates = coordAllCats(conditions);
medianStruct(n == 0) = [];
n(n == 0) = [];

%% Write montaged figure
[figures, metadata.intensityCutoffs] = maps2RGB(medianStruct, mapOrder, fieldNames, coordinates, conditions, n);
imshow(figures);
imwrite(figures, [settings.outRough, settings.uniqueIdentifier, 'AllFigureBody.png']);

%% Write Scale Bars
scaleBar = figures * 0;
scaleBar(10:20,10:(10+scaleBarPixels),:) = 255;
imwrite(scaleBar, [settings.outRough, settings.uniqueIdentifier, 'ScaleBarAll.png']);
   
%% Write colorbars
for i = 1:length(fieldNames)
    rawLegend = repmat(0:255, [40, 1]);
    imwrite(ind2rgb(rawLegend, mapOrder{i}), [settings.outRough, settings.uniqueIdentifier, [fieldNames{i} ' Legend.png']]);
end
    
%% Write scalebars
scaleBar = figures * 0;
scaleBar(10:20,10:(10+scaleBarPixels),:) = 255;
imwrite(scaleBar, [settings.outRough, settings.uniqueIdentifier, 'ScaleBar.png']);

metadata.fieldNames = fieldNames;