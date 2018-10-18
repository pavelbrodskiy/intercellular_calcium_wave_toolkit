function h = graphRawViolinPlot(data, category, logs, N, autoHist, catList, sortByMean)
%% Lazy parameters
if nargin < 7
    sortByMean = [];
end
if nargin < 6
    catList = unique(category);
end
if nargin < 5
    autoHist = true;%settings.histBins;
end
if nargin < 4
    N = 150;%settings.histBins;
end
if nargin < 3
    logs = false;
end

bootstrapNum = 5000;

if ~autoHist
    %% Make histograms
    raw = [];
    for i = 1:length(data)
        raw = [raw; data{i}(:)];
    end
    
    if logs
        raw(isnan(raw)) = [];
        raw = log(raw);
    end
    
    [~,edges] = discretize(raw,N);
    
    for i = 1:size(data, 1)
        for j = 1:size(data, 2)
            rawData = data{i,j};
            rawData(isnan(rawData)) = [];
            if logs
                meanHists(1:N,i,j) = histcounts(log(rawData),edges);
            else
                meanHists(1:N,i,j) = histcounts(rawData,edges);
            end
        end
    end
    
    %% Average cats
    if size(meanHists, 3) > 1
        for i = 1:length(catList)
            finalHistA = mean(meanHists(:,catList(i)==category, 1), 2);
            binsCountsA{i} = [((edges(1:end-1)+edges(2:end))/2)',finalHistA];
            
            finalHistP = mean(meanHists(:,catList(i)==category, 2), 2);
            binsCountsP{i} = [((edges(1:end-1)+edges(2:end))/2)',finalHistP];
        end
        
        
        %% Make figures
        for i = 1:length(catList)
            strCatList{i} = char(catList(i));
        end
        figure
        h1 = distributionPlot(binsCountsA,'xNames',strCatList,'showMM',0,'widthDiv',[2 1],'color',[1,0.3,0.3]);
        h2 = distributionPlot(binsCountsP,'xNames',strCatList,'showMM',0,'widthDiv',[2 2],'color',[0.3,1,0.3]);
        
        h = {h1, h2};
        
    else
        for i = 1:length(catList)
            finalHist = mean(meanHists(:,catList(i)==category, 1), 2);
            binsCounts{i} = [((edges(1:end-1)+edges(2:end))/2)',finalHist];
        end
        
        
        %% Make figures
        for i = 1:length(catList)
            strCatList{i} = char(catList(i));
        end
        figure
        h = distributionPlot(binsCounts,'xNames',strCatList,'showMM',0,'widthDiv',[1 1],'color',[0.3,0.3,0.3]);
        
    end
else
    switch size(data,2)
        case 1
            newData = {};
            for i = 1:length(catList)
                tmpData = [];
                for j = find(catList(i)==category)
                    tmpdata = data{j};
                    tmpdata(isnan(tmpdata)) = [];
                    [tmpRaw, ~] = bootstrp(round(bootstrapNum/200), @(x) x, tmpdata);
                    tmpRaw = tmpRaw(:);
                    tmpData = [tmpData; tmpRaw(1:bootstrapNum)];
                end
                newData{i} = tmpData;
            end
        case 2
            newDataA = {};
            newDataP = {};
            for i = 1:length(catList)
                tmpDataA = [];
                tmpDataP = [];
                for j = find(catList(i)==category)
                    tmpdataA = data{j,1};
                    tmpdataP = data{j,2};
                    tmpdataA(isnan(tmpdataA)) = [];
                    tmpdataP(isnan(tmpdataP)) = [];
                    [tmpRawA, ~] = bootstrp(round(bootstrapNum/200), @(x) x, tmpdataA);
                    [tmpRawP, ~] = bootstrp(round(bootstrapNum/200), @(x) x, tmpdataP);
                    tmpRawA = tmpRawA(:);
                    tmpRawP = tmpRawP(:);
                    tmpDataA = [tmpDataA; tmpRawA(1:bootstrapNum)];
                    tmpDataP = [tmpDataP; tmpRawP(1:bootstrapNum)];
                end
                newDataA{i} = tmpDataA;
                newDataP{i} = tmpDataP;
            end
        otherwise
            error('wrong sized data')
    end
end
if ~isempty(sortByMean)
    for i = 1:length(newData)
        dataMean(i) = mean(newData{i});
    end
    dataMean(sortByMean) = [];
    [~,idx] = sort(dataMean);
    
    catList = catList([sortByMean, idx+length(sortByMean)]);
    newData = newData([sortByMean, idx+length(sortByMean)]);
end
for i = 1:length(catList)
    strCatList{i} = char(catList(i));
end
switch size(data,2)
    case 1
        figure
        h = distributionPlot(newData,'divFactor',0.5,'histOpt',1.1,'xNames',strCatList,'showMM',5,'widthDiv',[1 1],'color',[0.3,0.3,0.3]);
    case 2
        figure
        h1 = distributionPlot(newDataA,'divFactor',0.5,'histOpt',1.1,'xNames',strCatList,'showMM',5,'widthDiv',[2 1],'color',[1,0.3,0.3]);
        h2 = distributionPlot(newDataP,'divFactor',0.5,'histOpt',1.1,'xNames',strCatList,'showMM',5,'widthDiv',[2 2],'color',[0.3,1,0.3]);
        
        h = {h1, h2};
    otherwise
        error('wrong data size')
end
end