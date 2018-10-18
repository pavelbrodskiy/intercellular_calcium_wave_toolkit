% This function makes a figure panel for control data with discs falling
% into different size bins.

function metadata = generateReport(structMaps, settings, category, labels, catList)
%% Declare parameters (Lazy)
fieldNames = settings.fieldNames;
mapOrder = settings.mapOrder;
cutoffPercentiles = [2, 98];
discsPerPage = 7;
scaleBar = 100;
sigFig = 2;
% cutoffs = {[0,180],[0, 5.2],[0,50],[0, 1000], [0, 4.4]};
cutoffs = settings.cutoffs;
logFields = settings.fieldLog;

%% Clean dataset
[category, structMapsReduced, labels] = cleanDataset(category, unique(catList)', structMaps, labels);
structMapsReduced = reduceStructFields(structMapsReduced, fieldNames);
maskSize = getPouchSizes(labels, settings);

%% Normalize spatial maps
figure = [];
for i = 1:length(fieldNames)
    values = {structMapsReduced.(fieldNames{i})};
    values = padStack(values);
    
    [X, Y, Z] = size(values{1});
    values = padStack(values, true, [X + 4, Y + 4]);
    
    values = cat(3, values{:});
    %     if i == 5
    %         values = values / 3600;
    %     end
    if logFields(i)
        tmpVals = log(values);
    else
        tmpVals = values(:);
    end
    tmpVals = tmpVals(:);
    tmpVals(isnan(tmpVals)) = [];
    tmpVals(isinf(tmpVals)) = [];
    if ~exist('cutoffs')
        cutoff(i,:) = roundsd(prctile(tmpVals(:), cutoffPercentiles), sigFig);
    else
        cutoff(i,:) = cutoffs{i};
    end
    if logFields(i)
        values = log(values+1e-9);
    end
    storeVals{i} = values;
end

[X, Y, Z] = size(values);

%% Make separate figures for SI
page = 1;
letters = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'};

for currentCat = unique(category)
    disp(['Making report for: ' char(currentCat)]);
    
    curIdx = currentCat == category;
    pouchSize = maskSize(curIdx);
    for j = 1:floor(length(pouchSize)/discsPerPage + 1)
        figure = [];
        tmpDiscs = {};
        for i = 1:length(fieldNames)
            values = storeVals{i};
            curValues = values(:,:,curIdx);
            [~, sortIdx] = sort(pouchSize);
            values = curValues(:,:,sortIdx);
            values = cat(3, nanmedian(values, 3), values);
            
            tmpVals = values(:,:,((j-1)*discsPerPage+2):(min((j*discsPerPage)+1,end)));
            
            tmpVal2 = tmpVals(:,:,1);
            tmpDiscs{1, i} = rescale2RGB(tmpVal2, 'map', mapOrder{i}, 'scale', cutoff(i,1:2));
            tmpFig = [values(:,:,1,end); nan(30,size(tmpVal2,2))];
            
            for m = 1:size(tmpVals, 3)
                tmpVal2 = tmpVals(:,:,m);
                tmpDiscs{m, i} = rescale2RGB(tmpVal2, 'map', mapOrder{i}, 'scale', cutoff(i,1:2));
                tmpFig = [tmpFig; tmpVals(:,:,m)];
            end
            
            figure = [figure rescale2RGB(tmpFig, 'map', mapOrder{i}, 'scale', cutoff(i,1:2))];
            imshow(figure)
            figure;
        end
        
        %         close all
        
        figure = cat(1,ones(70,size(figure,2),3)*255, figure, ones(20,size(figure,2),3)*255);
        
        scalePxls = scaleBar * settings.scale.x20;
        figure(end-16:end-10,end-10-scalePxls:end-10,:) = 0;
        
        colorBar = repmat((1:round(2*Y/3)), [9,1]);
        for m = 1:length(fieldNames)
            colorBarM = rescale2RGB(colorBar, 'map', mapOrder{m});
            figure((23:31)+14,((round(Y/3/2):(round(Y/3/2))+size(colorBarM,2)-1))+(m-1)*Y,1:3) = colorBarM;
        end
        
        [tmpX, tmpY, ~] = size(figure);
        figure((1:X)+67,1:2,:) = 0;
        figure((1:X)+67,end-2:end,:) = 0;
        figure((1:2)+67,1:tmpY,:) = 0;
        figure((X-2:X)+67,1:tmpY,:) = 0;
        
        imshow(figure)
        
        for n = 1:length(fieldNames)
            text(round(Y/2*(n*2-1)),14,settings.fieldLabelsTwoRow{n},'HorizontalAlignment','center')
            text((round(Y/3/2)+(n-1)*Y),41+14,num2str(cutoff(n,1)),'HorizontalAlignment','center');
            text(((round(Y/3/2))+size(colorBarM,2)-1)+(n-1)*Y,41+14,num2str(cutoff(n,2)),'HorizontalAlignment','center');
        end
        
        
        set(findall(gcf,'-property','FontSize'),'FontSize',10)
        %         set(findall(gcf,'-property','FontWeight'),'FontWeight','bold')
        
        for n = 1:length(fieldNames)
            tmpText = [letters{1}, repmat(char(39),[1, n-1])];
            text((n-1)*Y+5,(1-1)*X+8+70,tmpText,'FontSize',12, 'FontWeight', 'bold')
        end
        
        for m = 2:size(tmpVals, 3)
            for n = 1:length(fieldNames)
                tmpText = [letters{m}, repmat(char(39),[1, n-1])];
                text((n-1)*Y+5,(m-1)*X+8+70+30,tmpText,'FontSize',12, 'FontWeight', 'bold')
            end
        end
        
        
        
        set(findall(gcf,'-property','Font'),'Font','Arial')
        
        
        tmpa = char(currentCat);
        
        tmpa = strrep(tmpa, '\', '-');
        tmpa = strrep(tmpa, '/', '-');
        tmpa = strrep(tmpa, ':', '-');
        
        set(gcf, 'PaperUnits', 'inches');
        set(gcf, 'PaperSize', [6.5 6.5/size(figure,2)*size(figure,1)]);
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperPosition', [0 0 6.5 6.5/size(figure,2)*size(figure,1)]);
        
        export_fig([settings.outRough, settings.uniqueIdentifier, '_Report_page_' num2str(page) '_' char(tmpa)],  '-png', 'pdf', '-r600')
        
        % figuresize(6.5*size(figure,2)/size(figure,1), 6.5, 'inches')
        
        
        %         figurePlate = makeFigurePlate(tmpDiscs);
        %         print([settings.outRough, settings.uniqueIdentifier, '_Report_page_' num2str(page) '_' char(currentCat) '.png'], '-dpng', '-r600');
        %         imwrite(figure, [settings.outRough, settings.uniqueIdentifier, '_Report_page_' num2str(page) '_' char(currentCat) '.png']);
        page = page + 1;
    end
end

%% Write scalebars
scaleBarPixels = round(scaleBar / settings.scale.x20);
scaleBar = figure * 0;
scaleBar(10:20,10:(10+scaleBarPixels),:) = 255;
imwrite(scaleBar, [settings.outRough, settings.uniqueIdentifier, '_ReportScaleBar.png']);

metadata.cutoffs = cutoff;
