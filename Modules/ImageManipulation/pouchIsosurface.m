% Script to generate 3D isosurfaces from tiff stack data
% Adapted from J. kantor's scripts for image processing/visualization

function h = pouchIsosurface(video, mask, dirName, cutoffs, settings, pad, display)
%% Declare parameters
sigma = 3;
percentileBounds = [3, 97];
if isempty(mask)
    mask = ones(size(video, 1), size(video, 2));
end
if nargin < 6
    pad = 0;
end
if nargin < 7
    display = true;
end

%% Gaussian smoothing
video = imgaussfilt(double(video), sigma);
video(repmat(~mask, [1,1,size(video,3)])) = 0;

%% Threshold
video = video - double(repmat(min(video, [], 3), [1,1,size(video,3)]));
thresh = prctile(video(:), percentileBounds);
video = video - thresh(1);
video = video / (thresh(2) - thresh(1));
% video = padarray(video, [pad, pad, 0],'pre');
% video = padarray(video, [pad, pad, 0],'post');

%% define x, y, and t scale for isosurfaces
x = linspace(0, size(video, 2) * 0.7, size(video, 2)); % x axis in um
y = linspace(0, size(video, 1) * 0.7, size(video, 1)); % y axis in um
t = (0:(size(video, 3) - 1)) * settings.timestep; % time axis in seconds

%% Make isosurface
for i = cutoffs
    fileName = [dirName num2str(i) '.png'];
    if display||~exist(fileName, 'file')
        disp(['Making Isosurface cutoff = ', num2str(i)]);
        clf
        xshift = x - mean(x);
        yshift = y - mean(y);
        
        isosurface(xshift, yshift, t, double(video), i);
%         vert = PV.vertices;
%         vertx = round((vert(:,1) + mean(x)) / 0.7);
%         verty = round((vert(:,2) + mean(y)) / 0.7);
%         vertx(vertx==0) = 1;
%         verty(verty==0) = 1;
        
%         for i = 1:length(vertx)
%         	remove(i) = mask(verty(i),vertx(i));
%         end
        
%         PV.vertices(:,remove) = [];
%         patch(PV)
        
        daspect auto
        view(3); axis tight
        
        xlabel('x (\mum)');
        ylabel('y (\mum)');
        zlabel('time (s)');
        
        axis([min(x)-pad, max(x)+pad, min(y)-pad, max(y)+pad, -inf, inf])
        
        if display
            print(fileName, '-dpng', '-r120')
        end
    end
end
h = gca;

end

