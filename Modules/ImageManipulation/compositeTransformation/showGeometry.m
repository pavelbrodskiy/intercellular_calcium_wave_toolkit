% Plots the geometry on the mask. Can specify which of the two geometries
% is plotted. Can hide a fraction of the points in each direction.

function showGeometry(geometry, AP_or_DV, interval, linespec)
%% Parse inputs
if nargin < 2
    AP_or_DV = 'both';
end
if nargin < 3
    interval = [1,1];
end
if nargin < 4
    linespec = '.k';
end

%% Plot geometry
switch AP_or_DV
    case 'both'
        figure
        subplot(2,2,1)
        imshow(geometry.mask)
        hold on
        a = geometry.NCp(1:interval(1):end,1,1:interval(1):end);
        b = geometry.NCp(1:interval(1):end,2,1:interval(1):end);
        scatter(a(:),b(:),linespec);
        a = geometry.SCp(1:interval(2):end,1,1:interval(2):end);
        b = geometry.SCp(1:interval(2):end,2,1:interval(2):end);
        scatter(a(:),b(:),linespec);
        
        subplot(2,2,2)
        imshow(geometry.mask)
        a = geometry.ECp(1:interval(1):end,1,1:interval(1):end);
        b = geometry.ECp(1:interval(1):end,2,1:interval(1):end);
        scatter(a(:),b(:),linespec);
        hold on
        a = geometry.WCp(1:interval(2):end,1,1:interval(2):end);
        b = geometry.WCp(1:interval(2):end,2,1:interval(2):end);
        scatter(a(:),b(:),linespec);
        
    case 'AP'
        a = geometry.NCp(1:interval(1):end,1,1:interval(2):end);
        b = geometry.NCp(1:interval(1):end,2,1:interval(2):end);
        scatter(a(:),b(:),linespec);
        hold on
        a = geometry.SCp(1:interval(1):end,1,1:interval(2):end);
        b = geometry.SCp(1:interval(1):end,2,1:interval(2):end);
        scatter(a(:),b(:),linespec);        
    case 'DV'
        a = geometry.ECp(1:interval(1):end,1,1:interval(1):end);
        b = geometry.ECp(1:interval(1):end,2,1:interval(1):end);
        scatter(a(:),b(:),linespec);
        hold on
        a = geometry.WCp(1:interval(2):end,1,1:interval(2):end);
        b = geometry.WCp(1:interval(2):end,2,1:interval(2):end);
        scatter(a(:),b(:),linespec);
    otherwise
        error('AP_or_DV should be "both", "AP", or "DV"')
end