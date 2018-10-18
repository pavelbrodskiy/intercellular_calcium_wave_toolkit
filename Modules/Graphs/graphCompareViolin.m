function [h, test, pOut] = graphCompareViolin(data, catName, type)

catName = cellstr(catName);

for i = 1:length(data)
    A{i} = data{i}(:,1);
    P{i} = data{i}(:,2);
    
    [~, p] = ttest2(A{i}, P{i});
    test(i,1) = p;
    pOut(i,1) = stars(p);
    [~, p] = ttest2(A{1}, A{i});
    test(i,2) = p;
    pOut(i,2) = stars(p);
    [~, p] = ttest2(P{1}, P{i});
    test(i,3) = p;
    pOut(i,3) = stars(p);
end

if nargin < 3
    type = 'violin';
end
    
switch type
    case 'violin'
        figure
        h1 = distributionPlot(A,'widthDiv',[2 1],'color',[1,0.3,0.3],'showMM',5,'xNames',catName,'globalNorm',3)
        h1{2}(1).Color = [0,0,0];
        h1{2}(2).Color = [0,0,0];
        h2 = distributionPlot(gca,P,'widthDiv',[2 2],'color',[0.3,1,0.3],'showMM',5,'globalNorm',3)
        h2{2}(1).Color = [0,0,0];
        h2{2}(2).Color = [0,0,0];
        
        h = {h1, h2};
        
    case 'violinHalfHalf'
        figure
        h1 = distributionPlot(A,'addSpread',1,'widthDiv',[2 1],'histOri','left','color',[1,0.3,0.3],'showMM',5,'xNames',catName)
        h1{2}(1).Color = [0,0,0];
        h1{2}(2).Color = [0,0,0];
        h2 = distributionPlot(gca,P,'addSpread',1,'widthDiv',[2 2],'histOri','right','color',[0.3,1,0.3],'showMM',5)
        h2{2}(1).Color = [0,0,0];
        h2{2}(2).Color = [0,0,0];
        
        h = {h1, h2};
    case 'raw data'
        figure
        h1 = distributionPlot(A,'addSpread',1,'widthDiv',[2 1],'histOri','left','color',[1,1,1],'showMM',5,'xNames',catName)
        h1{2}(1).Color = [0,0,0];
        h1{2}(2).Color = [0,0,0];
        h2 = distributionPlot(gca,P,'addSpread',1,'widthDiv',[2 2],'histOri','right','color',[1,1,1],'showMM',5)
        h2{2}(1).Color = [0,0,0];
        h2{2}(2).Color = [0,0,0];
        
        h = {h1, h2};
    otherwise
        error('Not a real plot type')
end

end

function n = stars(p)
n = sum(p<[0.05,0.01,0.001, 0.0001]);
end
