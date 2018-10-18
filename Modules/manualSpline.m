function [axisPoints, annotation] = manualSpline(I, mask, color)
if nargin < 3
    color = 'red';
end

annotation = rescale2RGB(I);
annotation = stampMask(annotation, mask);

% done = false;
% x = []; y = [];
% while ~done
%     annotationTmp = drawAnnotation(annotation, x, y, repmat({color}, size(x)));
%     imshow(annotationTmp, []);
%     [xPoint, yPoint, button] = ginput(1);
%     
%     if xPoint > size(annotationTmp, 2) / 2
%         xPoint = xPoint - size(annotationTmp, 2) / 2;
%     end
%     if yPoint > size(annotationTmp, 1) / 2
%         yPoint = yPoint - size(annotationTmp, 1) / 2;
%     end
%     
%     switch button
%         case 1 % Left, add
%             x = [x xPoint];
%             y = [y yPoint];
%         case 2 % Middle, end
%             done = true;
%         case 3
%             [~, idx] = min((x - xPoint).^2 + (y - yPoint).^2);
%             x(idx) = [];
%             y(idx) = [];
%         otherwise
%             error('Unidentified mouse button')
%     end
% end
flag = 0;
while flag == 0
    imshow(annotation,'InitialMagnification',100);
    title('Drag around relevent axis. Press "n" to accept, "r" to reset.');
    h = imfreehand('Closed',false);
    flag = confirm();
end
    axisPoints = fliplr(h.getPosition);

% annotation = annotationTmp;

centroid = mean(axisPoints, 1);

if centroid(1) > (size(annotation, 1) / 2)
    axisPoints(:,1) = axisPoints(:,1) - size(annotation, 1) / 2;
end
if centroid(2) > (size(annotation, 2) / 2)
    axisPoints(:,2) = axisPoints(:,2) - size(annotation, 2) / 2;
end
invalid = axisPoints(:,1) > (size(annotation, 1) / 2) | axisPoints(:,2) > (size(annotation, 2) / 2);
axisPoints(invalid,:) = [];
end

%% Make the output screen
function annotation = drawAnnotation(annotation, x, y, color)
if ~isempty(x)
    annotation = insertShape(annotation,'FilledCircle',[x', y', 2*ones(size(x))'],'Color', color, 'Opacity', 1);
end
end

%% Check if cancel
function stoploop = confirm()
stoploop = 0;
currkey = -1;
while currkey == -1
    pause;
    currkey = get(gcf,'CurrentKey');
    if strcmp(currkey, 'n')
        currkey = 1;
    elseif strcmp(currkey, 's')
        currkey = 0;
    elseif strcmp(currkey, 'r')
        currkey = 0;
    else
        currkey = 0;
    end
end
stoploop = currkey;
% if currkey == 2
%     flag = 0;
%     stoploop = 1;
% end
% if currkey == 3
%     stoploop = 2;
% end
end 
    
    
    
    
    
    