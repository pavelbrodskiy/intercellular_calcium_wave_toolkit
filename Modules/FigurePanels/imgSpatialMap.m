function metadata = imgSpatialMap(structMaps, settings, category, catList, sizeBins, pouchSizes, method)
% This function generates spatial composites.
%
% metadata = imgSpatialMap(settings)
% metadata = imgSpatialMap(settings, data)
% metadata = imgSpatialMap(settings, data, categories)
% metadata = imgSpatialMap(settings, data, categories, activeCategories)
% metadata = imgSpatialMap(settings, categories)
% metadata = imgSpatialMap(settings, categories, activeCategories)

%% Parse function inputs
% settings.compositeMethod = 'Isometric';
% 
% settings.inputParser = inputParser;
% 
% addOptional(settings.inputParser,'data', [], @isstruct);
% addOptional(settings.inputParser,'categoryArray', [], @iscategorical);
% addOptional(settings.inputParser,'pouchSizes', [], @isnumeric);
% addOptional(settings.inputParser,'activeCategories', [], @iscategorical);
% 
% addOptional(settings.inputParser,'labels', [], @iscell);
% addOptional(settings.inputParser,'sizeBins', [], @iscategorical);
% addOptional(settings.inputParser,'compositeMethod', settings.compositeMethod, @ischar);
% 
% parse(settings.inputParser, varargin{:});
% 
% loadData = isempty(data);
% haveIdentities = isemtpy(labels) || isempty(data);
% loadCatArray = isempty(categoryArray) && ~isempty(activeCategories);
% loadPouchSize = isempty(pouchSizes) && ~isempty(sizeBins);
% 
% if loadCatArray && ~haveIdentities
%    warning('Cannot load category identities without identifying information') 
% end
% if loadPouchSize && ~haveIdentities
%    warning('Cannot load pouch size identities without identifying information') 
% end

%% Declare parameters (Lazy)
fieldNames = settings.fieldNames;
fieldLabels = settings.fieldLabelsTwoRow;
mapOrder = settings.mapOrder;
cutoffPercentiles = [2, 98];
scaleBar = 100;
minX = 80;
minY = 110;
cutoffs = settings.cutoffs;
sigFigs = 1;
logFields = settings.fieldLog;
if nargin < 5
    sizeBins = [0, inf];
    pouchSizes = zeros(size(structMaps))+1e-4;
end
if nargin < 7
    method = 2;
end

%% Clean dataset
keep = zeros(size(category));
for currentCat = unique(catList)'
    keep(category == currentCat) = 1;
end
structMaps(~keep) = [];
category(~keep) = [];
pouchSizes(~keep) = [];
structMapsReduced = reduceStructFields(structMaps, fieldNames);

%% Split dataset by bin size
sizeBin = nan(size(pouchSizes))';
for i = 1:length(sizeBins) - 1
    sizeBin(pouchSizes > sizeBins(i) & pouchSizes <= sizeBins(i+1)) = i;
end

%% Normalize spatial maps
for i = 1:length(fieldNames)
    % Make all of the spatial maps the same size
    values = {structMapsReduced.(fieldNames{i})};
    values = padStack(values);
    [X, Y, Z] = size(values{1});
    X = max(minX, X);
    Y = max(minY, Y);
    values = padStack(values, true, [X, Y]);
    
    % Turn spatial maps into a 3D matrix
    values = cat(3, values{:});
    
    % Get cutoffs
    % If you are taking the log, then make sure that 0 is treated correctly
    if logFields(i)
        tmpVals = values(:);
        tmpLogs = log(tmpVals);
        tmpLogs(tmpVals<=0) = [];
        if ~exist('cutoffs')
            cutoff(i,:) = roundsd(prctile(tmpLogs(:), cutoffPercentiles), sigFigs);
        else
            cutoff(i,:) = cutoffs{i};
        end
        logValues = log(values);
        logValues(values <= 0) = cutoff(i,1);
        storeVals{i} = logValues;
    % If you are not taking the log, then display as usual
    else
        tmpVals = values(:);
        if ~exist('cutoffs')
            cutoff(i,:) = roundsd(prctile(tmpVals(:), cutoffPercentiles), sigFigs);
        else
            cutoff(i,:) = cutoffs{i};
        end
        storeVals{i} = values;
    end
            
            
    
    
%     if logFields(i)
%         values(values < cutoff(i,1)) = cutoff(i,1);
%         values(values >= cutoff(i,2)) = cutoff(i,2);
%         cutoff(i,:) = log(cutoff(i,:));
%         values = log(values);
%     end
%     
%     values(values == inf) = max(tmpVals(:));
%     values(values == -inf) = min(tmpVals(:));
%     storeVals{i} = values;
end

% for  i = 1:length(fieldNames)
% %    cutoff(i,:)= roundsd(cutoff(i,:)  
% end

[X, Y, Z] = size(values);

%% Write image files
n = [];
catList = unique(category)';
for i = 1:length(fieldNames)
    allImages = storeVals{i};
    for k = 1:length(catList)
        currentCat = catList(k);
        for j = unique(sizeBin)'
            if isnan(j)
                continue
            end
            disp(['Writing images for: ' char(currentCat), ' ', fieldNames{i}, ' ' num2str(sizeBins(j)) '_to_' num2str(sizeBins(j+1))]);
            active = category == currentCat & sizeBin == j;
            n(k,j) = sum(active);
            if sum(active) == 0
                continue
            end
            
            switch method
                case 1
                    % REPLACE WITH medianProjectSpatialMaps(structMaps,
                    % category) LATER
                    zProjection = nanmedian(allImages(:,:,active), 3);
                case 2
                    rawStack = allImages(:,:,active);
                    masks = zeros(size(rawStack));
                    masks(~isnan(rawStack)) = 1;
                    maskComposite = nanmean(double(masks),3);
                    maskComposite = maskComposite > 0.5;
                    zProjection = nanmedian(rawStack,3);
                    zProjection(~maskComposite) = nan;
                otherwise
                    error('wrong case')
            end
            composite = rescale2RGB(zProjection, 'map', mapOrder{i}, 'scale', cutoff(i,1:2));
            composite = cropWhite(composite);
            
            imshow(composite)
            
            tmpa = char(currentCat);
            
            tmpa = strrep(tmpa, '\', '-');
            tmpa = strrep(tmpa, '/', '-');
            tmpa = strrep(tmpa, ':', '-');
            
            export_fig([settings.outRough, 'annotationImage_' tmpa '_' fieldNames{i} '_' settings.uniqueIdentifier,  '_size_' num2str(sizeBins(j)) '_to_' num2str(sizeBins(j+1)) '.png'], '-r300', '-transparent')
        end
    end
end

%% Make annotation image
% Pad labels and scale bar
figure = ones(120,Y*length(fieldNames),3,'uint8') * 255;
scalePxls = scaleBar * settings.scale.x20;
figure(end-16:end-10,end-10-scalePxls:end-10,:) = 0;

%% Colorbars
colorBar = repmat((1:round(2*Y/3)), [9,1]);
for m = 1:length(fieldNames)
    colorBarM = rescale2RGB(colorBar, 'map', mapOrder{m});
    figure((23:31)+14,((round(Y/3/2):(round(Y/3/2))+size(colorBarM,2)-1))+(m-1)*Y,1:3) = colorBarM;
end

imshow(figure)

%% Text labels horizontal
for i = 1:length(fieldLabels)
    text(round(Y/2*(2*i-1)),14,fieldLabels{i},'HorizontalAlignment','center')
end

for i = 1:length(fieldNames)
    text((round(Y/3/2)+(i-1)*Y),41+14,num2str(cutoff(i,1)),'HorizontalAlignment','center');
    text(((round(Y/3/2))+size(colorBarM,2)-1)+(i-1)*Y,41+14,num2str(cutoff(i,2)),'HorizontalAlignment','center');
end

set(findall(gcf,'-property','FontSize'),'FontSize',10)
set(findall(gcf,'-property','Font'),'Font','Arial')

tmpa = char(currentCat);

tmpa = strrep(tmpa, '\', '-');
tmpa = strrep(tmpa, '/', '-');
tmpa = strrep(tmpa, ':', '-');

export_fig([settings.outRough, 'annotationImage_' char(tmpa),'_', settings.uniqueIdentifier, '.png'], '-r300', '-transparent')

%% Text labels vertical
% figure = ones(300,300,3,'uint8') * 255;
% for i = 1:length(fieldLabels)
%     text(150,14+40*(i-1),fieldLabels{i},'HorizontalAlignment','center')
% end
%
% for n = 1:length(fieldNames)
%     text((round(Y/3/2)+(n-1)*Y),41+14,num2str(cutoff(n,1)),'HorizontalAlignment','center');
%     text(((round(Y/3/2))+size(colorBarM,2)-1)+(n-1)*Y,41+14,num2str(cutoff(n,2)),'HorizontalAlignment','center');
% end
%
% set(findall(gcf,'-property','FontSize'),'FontSize',10)
% set(findall(gcf,'-property','Font'),'Font','Arial')
%
% tmpa = char(currentCat);
%
% tmpa = strrep(tmpa, '\', '-');
% tmpa = strrep(tmpa, '/', '-');
% tmpa = strrep(tmpa, ':', '-');
%
% export_fig([settings.outRough, 'annotationImage_' char(tmpa),'_', settings.uniqueIdentifier, '.png'], '-r300', '-transparent')

metadata.cutoff = cutoff;
metadata.n = n;
end


