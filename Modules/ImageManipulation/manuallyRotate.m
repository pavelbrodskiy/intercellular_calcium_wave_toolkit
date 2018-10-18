function manuallyRotate(label, settings)

close all

video = readTiff([settings.inExperimentalData label '.tif']);

h.Zproj = figure;
zProjection = double(max(video, [], 3));
annotated2D = rescale2RGB(zProjection);
figure(1)
imshow(video(:,:,100),[]);
figure(2)
imshow(annotated2D);

%% Select P, A, D, V points
[Py, Px] = ginputc(1);
annotated2D = insertShape(annotated2D,'FilledCircle',[Py, Px, 3],'Color','red');
imshow(annotated2D);
[Ay, Ax] = ginputc(1);
annotated2D = insertShape(annotated2D,'FilledCircle',[Ay, Ax, 3],'Color','red');
imshow(annotated2D);
theta = atand((Px-Ax)/(Py-Ay));
rotatedVideo = imrotate(video,theta);
annotated2D = imrotate(annotated2D,theta);
imshow(annotated2D);

%% Select P, A, D, V points
[y(1), x(1)] = ginputc(1);
annotated2D = insertShape(annotated2D,'FilledCircle',[y(1), x(1), 3],'Color','blue');
imshow(annotated2D);
[y(2), x(2)] = ginputc(1);
annotated2D = insertShape(annotated2D,'FilledCircle',[y(2), x(2), 3],'Color','blue');
imshow(annotated2D);
[y(3), x(3)] = ginputc(1);
annotated2D = insertShape(annotated2D,'FilledCircle',[y(3), x(3), 3],'Color','blue');
imshow(annotated2D);
[y(4), x(4)] = ginputc(1);
annotated2D = insertShape(annotated2D,'FilledCircle',[y(4), x(4), 3],'Color','blue');
imshow(annotated2D);

%% Rotate and crop video
annotated2D = annotated2D(min(x):max(x), min(y):max(y));
croppedVideo = rotatedVideo(min(x):max(x), min(y):max(y),:);
annotated2D2 = annotated2D;
croppedVideo2 = croppedVideo;
if x(4) > x(3)
    annotated2D2 = flipud(annotated2D2);
    croppedVideo2 = flipud(croppedVideo2);
end
if y(1) < y(2)
    annotated2D2 = fliplr(annotated2D2);
    croppedVideo2 = fliplr(croppedVideo2);
end
close all
subplot(2,2,1)
imshow(annotated2D, [])
subplot(2,2,2)
imshow(croppedVideo(:,:,1), [])
subplot(2,2,3)
imshow(annotated2D2, [])
subplot(2,2,4)
imshow(croppedVideo2(:,:,1), [])
croppedVideo = croppedVideo2;
%% Export video
% ginput(1)
save([settings.thruRot label '.mat'], 'croppedVideo', 'annotated2D2', 'x', 'y', 'Px', 'Ax', 'Py', 'Ay', '-v7.3');

end