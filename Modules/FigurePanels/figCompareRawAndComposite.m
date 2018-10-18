% This function makes a figure panel for control data with discs falling
% into different size bins.

function metadata = figCompareRawAndComposite(structMaps, settings, category, currentCat, labels, fieldNames)
%% Parse Inputs (Lazy)
if nargin < 6
    fieldNames = settings.fieldNames;
    mapOrder = settings.mapOrder;
else
    maps = settings.colorMap;
    for i = 1:length(fieldNames)
       mapOrder{i} = maps.amp; 
    end
end
scaleBar = 50;

%% Initialization
scaleBarPixels = round(scaleBar / settings.scale.x20);
structMaps = structMaps(currentCat == category);
labels = labels(currentCat == category);
category = category(currentCat == category);
structMapsReduced = reduceStructFields(structMaps, fieldNames);

%% Median projections of controls by category
medianStruct = medianProjectSpatialMaps(structMapsReduced, category');
structMapsDisplay = padStructureStack([medianStruct structMapsReduced]);
n = length(structMapsDisplay);
coordinates = [zeros(1,n); 0:(n-1)];
conditions = [currentCat categorical(labels)'];
n = [n ones(1, n)];

%% Write montaged figure
[figures, metadata.intensityCutoffs] = maps2RGB(structMapsDisplay, mapOrder, fieldNames, coordinates, conditions, n, settings.analysis.binSize / settings.sizeStandard);
imwrite(figures, [settings.outRough, settings.uniqueIdentifier, '_' char(currentCat), 'FigureBody.png']);

%% Write Scale Bars
scaleBar = figures * 0;
scaleBar(10:20,10:(10+scaleBarPixels),:) = 255;
imwrite(scaleBar, [settings.outRough, settings.uniqueIdentifier, '_ScaleBarAll.png']);
   
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