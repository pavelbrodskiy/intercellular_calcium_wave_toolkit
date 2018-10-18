function figurePlate = makeFigurePlate(imgSpatialMaps)

[M, N] = size(imgSpatialMaps);

figurePlate = panel();
figurePlate.pack(5, 5);

% p.de.margin = 0;
% p(1,1).marginbottom = 20;
% p(2).marginleft = 20;
figurePlate.margin = [0 0 0 0];
% figurePlate.de.margin = 0;

for m = 1:M
    for n = 1:N
        figurePlate(m, n).select();
        imshow(imgSpatialMaps{m,n});
        text(10,10,'a')
%         figurePlate(m,n).margin = [0 0 0 0];
    end
end

figurePlate.select('all');

end

