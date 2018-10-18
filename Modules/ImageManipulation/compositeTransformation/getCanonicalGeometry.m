function [canonical2, canonical] = getCanonicalGeometry(settings)
if nargin == 0
    settings = getSettings;
    close all
end

%% Inputs
settings.canonicalXY = 500;
settings.meridians_canonical = 500;

%% Generate inputs
[X, Y] = meshgrid(1:settings.canonicalXY, 1:settings.canonicalXY);
mask = sqrt((X-settings.canonicalXY/2).^2 + (Y-settings.canonicalXY/2).^2) < settings.canonicalXY/2;

%% Generate canonical geometry
r = settings.canonicalXY / 2;
xs = linspace(0, r, settings.meridians_canonical);
settings.meridians = settings.meridians * 2;
for i = length(xs):-1:1
    x = xs(i);
    y = sqrt(r.^2 - (x-r).^2);
    meridians_y(i,:) = linspace(r + y, r - y, settings.meridians*2);
    meridians_x(i,:) = x * ones(settings.meridians*2, 1);
end

for i = settings.meridians*2:-1:1
    pts(:,:,i) = interparc(linspace(0,1,settings.meridians /2),meridians_x(:,i),meridians_y(:,i), 'linear');
end
pts(:,:,settings.meridians+1:end) = flip(pts(:,:,settings.meridians+1:end), 3);
canonical.NCp = permute(pts,[3,2,1]);

xs = linspace(r, 2*r, settings.meridians_canonical);
for i = length(xs):-1:1
    x = xs(i);
    y = sqrt(r.^2 - (x-r).^2);
    meridians_y(i,:) = linspace(r + y, r - y, settings.meridians*2);
    meridians_x(i,:) = x * ones(settings.meridians*2, 1);
end

clear pts
for i = settings.meridians*2:-1:1
    pts(:,:,i) = interparc(linspace(0,1,settings.meridians /2),meridians_x(:,i),meridians_y(:,i), 'linear');
end

pts(1,:,:) = [];
pts(:,:,settings.meridians+1:end) = flip(pts(:,:,settings.meridians+1:end), 3);

canonical.SCp = permute(pts,[3,2,1]);

canonical.ECp(:,1,:) = canonical.SCp(:,2,:);
canonical.ECp(:,2,:) = canonical.SCp(:,1,:);
canonical.WCp(:,1,:) = canonical.NCp(:,2,:);
canonical.WCp(:,2,:) = canonical.NCp(:,1,:);

canonical.NCp = canonical.ECp;
canonical.SCp = canonical.WCp;


% canonical.NCp = [];% canonical.WCp;
% canonical.SCp = [];%= canonical.ECp;

canonical.NCp = cat(3, canonical.SCp, canonical.NCp);
tmp = canonical.NCp(:,2,:);
canonical.NCp(:,2,:) = canonical.NCp(:,1,:);
canonical.NCp(:,1,:) = tmp;

canonical.SCp = [];

canonical.mask = mask;

if nargin == 0
    a = canonical.NCp(:,1,:);
    b = canonical.NCp(:,2,:);
    scatter(a(:), b(:), [], 1:length(a(:)));
    axis equal
    axis ij
end

%canonical.NCp = canonical.NCp([61:120,60:-1:1],:,:);
canonical2 = makeCompositeGeometry(canonical);


