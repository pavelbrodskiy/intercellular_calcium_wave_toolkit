% This function makes a figure panel for control data with discs falling
% into different size bins.

function metadata = figControlComposites(structMaps, labels, settings, category)
%% Parse Inputs (Lazy)
fieldNames = {'meannormAmplitudes','meanfrequencies','meandutyCycles','meanbasal'};
fieldLabels = {'Amplitude (%)','Frequency (mHz)','Duty Cycle (%)','Basal Level (a.u.)'};
maps = settings.colorMap;
mapOrder = {maps.amp, maps.freq, maps.dtyCyc, maps.basal};
sizeBins = 4;
binCutoffs = (100/sizeBins):(100/sizeBins):(100-100/sizeBins);

%% Initialization
maskSize = getPouchSizes(labels, settings);
structMapsReduced = reduceStructFields(structMaps, fieldNames);
scaleBar = 50;
scaleBarPixels = round(scaleBar / settings.scale.x20);

if length(binCutoffs) < sizeBins - 1
    error('The number of size bins generated was not the expected amount.')
end

%% Median project maps
[medianStruct, metadata] = projectControls(category, structMapsReduced, maskSize);

%% Write montaged figure
[figures, metadata.intensityCutoffs] = maps2RGB(medianStruct, mapOrder, fieldNames);
imwrite(figures, [settings.outRough, settings.uniqueIdentifier, '_ControlFigureBody.png']);
    
%% Write colorbars
for i = 1:length(fieldNames)
    rawLegend = repmat(0:255, [40, 1]);
    imwrite(ind2rgb(rawLegend, mapOrder{i}), [settings.outRough, settings.uniqueIdentifier, [fieldNames{i} ' Legend.png']]);
end
    
%% Write scalebars
scaleBar = figures * 0;
scaleBar(10:20,10:(10+scaleBarPixels),:) = 255;
imwrite(scaleBar, [settings.outRough, settings.uniqueIdentifier, 'ScaleBar.png']);

