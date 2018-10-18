function longlat = visualizeGeometry(geometry, sizeRot, gridSize)
if nargin < 3
gridSize = 60;
end

NCp = geometry.NCp(round(linspace(1,size(geometry.NCp,1),gridSize/2)),:,round(linspace(1,size(geometry.NCp,3),gridSize)));
if isempty(geometry.SCp)
    SCp = [];
else
    SCp = geometry.SCp(round(linspace(1,size(geometry.SCp,1),gridSize/2)),:,round(linspace(1,size(geometry.SCp,3),gridSize)));
end

x = []; y = [];
for i = 1:size(NCp, 3)-1
    for j = 1:size(NCp, 1)-1
    [x1, y1] = bresenham(NCp(j,1,i),NCp(j,2,i),NCp(j+1,1,i),NCp(j+1,2,i));
    x = [x x1'];
    y = [y y1'];
    [x1, y1] = bresenham(NCp(j,1,i),NCp(j,2,i),NCp(j,1,i+1),NCp(j,2,i+1));
    x = [x x1'];
    y = [y y1'];
    end
end
if ~isempty(geometry.SCp)
for i = 1:size(SCp, 3)-1
    for j = 1:size(SCp, 1)-1
    [x1, y1] = bresenham(SCp(j,1,i),SCp(j,2,i),SCp(j+1,1,i),SCp(j+1,2,i));
    x = [x x1'];
    y = [y y1'];
    [x1, y1] = bresenham(SCp(j,1,i),SCp(j,2,i),SCp(j,1,i+1),SCp(j,2,i+1));
    x = [x x1'];
    y = [y y1'];
    end
end
end
a = x == 0 | y == 0;
x(a) = [];
y(a) = [];
a = x > sizeRot(2) | y > sizeRot(2);
x(a) = [];
y(a) = [];
idx = sub2ind([sizeRot(2), sizeRot(1)], x, y);
longlat = zeros([sizeRot(2), sizeRot(1)], 'logical');
longlat(idx) = 1;