% imgStats(statArray, coords, category, catList, geometries, sizeBins, pouchSizes)
% imgStats(settings, dataTable, catList, sizeBins)

function metadata = imgStats(settings, varargin)

%% Check for data table input
if istable(varargin{1})
    statArray = varargin{1}.statsArray;
    coords = varargin{1}.coords;
    category = varargin{1}.category;
    geometries = varargin{1}.geometries;
    pouchSizes = varargin{1}.pouchSizes;
    catList = varargin{2};
    sizeBins = varargin{3};
else
    statArray = varargin{1};
    coords = varargin{2};
    category = varargin{3};
    catList = varargin{4};
    geometries = varargin{5};
    sizeBins = varargin{6};
    pouchSizes = varargin{7};
    
    if nargin < 6
        sizeBins = [-inf, inf];
    end

end

%% Declare parameters (Lazy)
fieldNames = settings.fieldNames;
fieldLabels = settings.fieldLabelsTwoRow;
mapOrder = settings.mapOrder;
% cutoffPercentiles = [2, 98];
scaleBar = 100;
% minX = 80;
% minY = 110;
cutoffs = settings.cutoffs;
sigFigs = 1;


%% Obtain list of categories
if isempty(catList)
    catList = unique(category);
end

%% Clean dataset
keep = zeros(1,length(category));
for currentCat = 1:length(catList)
    keep(category == catList(currentCat)) = 1;
end

statArray(~keep) = [];
coords(~keep) = [];
category(~keep) = [];
geometries(~keep) = [];
pouchSizes(~keep) = [];

%% Split dataset by bin size
% Determine which size bin each disc belongs to
sizeBin = nan(size(pouchSizes))';
for i = 1:length(sizeBins) - 1
    sizeBin(pouchSizes > sizeBins(i) & pouchSizes <= sizeBins(i+1)) = i;
end

% Rename the category names to include size bin
for i = 1:length(category)
    category(i) = categorical({[char(category(i)), '_size_' num2str(sizeBins(sizeBin(i))) '_to_' num2str(sizeBins(sizeBin(i)+1))]});
end
catList = unique(category);

%% Transform spatial maps
for i = 1:length(catList)
    n(i) = sum(category==catList(i));
    for j = 1:length(fieldNames)
        disp(['Transforming category ' num2str(i) ' of ' num2str(length(catList)) ', field ' num2str(j) ' of ' num2str(length(fieldNames))]);
        transformed{i,j} = transformStatCoords({statArray(category==catList(i)).(fieldNames{j})}, coords(category==catList(i)), geometries(category==catList(i)));
    end
end

%% Obtain cutoffs automatically
for i = 1:length(fieldNames)
    if isempty(cutoffs{i})
        tmp = [];
        for j = 1:size(transformed, 1)
            tmp2 = transformed{j,i};
            tmp = [tmp; tmp2(:)];
        end
        cutoff(i,:) = prctile(tmp, [0.1, 99]);
    else
        cutoff(i,:) = cutoffs{i};
    end
end

%% Colorize and save composites
for i = 1:length(catList)
    for j = 1:length(fieldNames)
        zProjection = nanmedian(transformed{i,j}, 3);
        composite = rescale2RGB(zProjection, 'map', mapOrder{j}, 'scale', cutoff(j,1:2));
        composite = cropWhite(composite);
        
        imshow(composite)
        
        tmpa = char(catList(i));
        
        tmpa = strrep(tmpa, '\', '-');
        tmpa = strrep(tmpa, '/', '-');
        tmpa = strrep(tmpa, ':', '-');
        
        export_fig([settings.outRough, tmpa '_' fieldNames{j} '.png'], '-r600', '-transparent')
    end
end

metadata.cutoff = cutoff;
metadata.n = n;
return

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

export_fig([settings.outRough, 'annotationImage_' char(tmpa), '.png'], '-r600', '-transparent')

metadata.cutoff = cutoff;
metadata.n = n;
end


