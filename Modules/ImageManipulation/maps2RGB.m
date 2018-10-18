% Input a 1*B structure array, with S fields which are 2D spatial maps of
% doubles. Output an RGB figure with panels for the categories (B) across
% and summary statistics (S) down.

function [figure, cutoffs] = maps2RGB(dataStruct, varargin)
%% Parse parameters
cutoffPercentiles = [0, 98.8];
textBack = 255;
textColor = 'black';
fontSize = 10;
% Bug when figures are not all the same size.

if nargin == 2 % do default settings
    settings = varargin{1};
    maps = settings.mapOrder;
    f = settings.fieldNames;
    cutoffMat = settings.cutoffs;
else
    maps = varargin{1};
    f = varargin{2};
    varargin(1:2) = [];
end

if nargin <= 3 % If the coordinates are not specified
    %% Initialization
    S = length(f);
    figure = [];
    
    for i = 1:S
        values = {dataStruct.(f{i})};
        values = padStack(values);
        values = [values{:}];
        
        %% Determine cutoffs for summary stats
if ~exist('cutoffMat')
        cutoffTemp = prctile(values(:), cutoffPercentiles);
        cutoffs(i,1:2) = roundsd(cutoffTemp, 2);
        else
cutoffs(i,1:2) = cutoffMat{i};
end
        %% Normalize data to 8-bit by cutoffs
        figure = uint8([figure; rescale2RGB(values, 'map', maps{i}, 'scale', cutoffs(i,1:2))]);
    end
else % Follow the coordinates (2xN)
    coordinates = varargin{1};
    conditions = varargin{2};
    n = varargin{3};
    if nargin > 6
        resize = varargin{4};
    else
        resize = 1;
    end
    
    fontSize = fontSize * resize;
    
    %% Initialization
    S = length(f);
    a = dataStruct.(f{1});
    [x, y] = size(imresize(a,resize));
    maxDim = max(coordinates, [], 2);
    
    figure = [];
    for i = 1:S
        tmpFigure = ones(x*(maxDim(2)+1), y*(maxDim(1)+1), 3, 'uint8') * textBack;
        %% Determine cutoffs for summary stats
        values = [dataStruct.(f{i})];
        cutoffTemp = prctile(values(:), cutoffPercentiles);
        cutoffs(i,1:2) = roundsd(cutoffTemp, 2);
        for j = 1:length(dataStruct)
            values = dataStruct(j).(f{i});
            %% Normalize data to 8-bit by cutoffs
            d = rescale2RGB(values, 'map', maps{i}, 'scale', cutoffs(i,1:2), 'resize', resize);
            textStrip = ones(fontSize * 2, y, 3, 'uint8') * textBack;
            textStrip = insertText(textStrip, [round(y/2), fontSize*0.5], char(conditions(j)), 'BoxOpacity', 0, 'AnchorPoint', 'Center', 'TextColor', textColor, 'FontSize', fontSize);
            textStrip = insertText(textStrip, [round(y/2), fontSize*1.5], ['n = ' num2str(n(j))], 'BoxOpacity', 0, 'AnchorPoint', 'Center', 'TextColor', textColor, 'FontSize', fontSize);
            d = [d; textStrip];
            xNew = x + fontSize * 2;
            tmpFigure((xNew*coordinates(2, j)+1):((xNew*(coordinates(2, j)+1))), ...
                (y*coordinates(1, j)+1):((y*(coordinates(1, j)+1))),:) = d;
            
        end
        figure = [figure, tmpFigure];
    end
    
end