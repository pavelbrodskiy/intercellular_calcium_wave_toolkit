
function identifyOrientation(settings)


%% Initialization
if(~testConsensus())
    error('Consensus testing is not working')
end

tblAnalysis = readtable([settings.inTables,'flipAPDV.xlsx'],'ReadRowNames',true);
labels = tblAnalysis.Label;
% [APMat, DVMat] = getAxes(labels, settings);
% PB1 = categorical(tblAnalysis.PB1);
% PB2 = categorical(tblAnalysis.PB2);
% PB3 = categorical(tblAnalysis.PB3);
% PB4 = categorical(tblAnalysis.PB4);
% PB5 = categorical(tblAnalysis.PB5);
% [~, F] = mode([PB1, PB2, PB3, PB4, PB5], 2);
% skip = (PB1 == PB2) & (PB1 == PB3);
% F = uint8(F) + uint8(skip) * 2;
% tblAnalysis.PB6(F > 3) = {'skip'};
% tblAnalysis.PB7(F > 3) = {'skip'};
% tblAnalysis.PB8(F > 3) = {'skip'};
% writetable(tblAnalysis, 'flipAPDV.xlsx','WriteRowNames', true);

%% Show rotated images
while true
    toDo = find(strcmp(tblAnalysis.consensus,'empty'));
    
    disp([num2str(round(100 - 100*length(toDo)/size(tblAnalysis,1))) '% done.']);
    
    if isempty(toDo)
        break
    end
    
    i = toDo(randperm(length(toDo), 1));
    idx = find(strcmp(tblAnalysis{i, 2:end}, 'empty'));
    k = idx(1) + 1;
    
    path = [settings.thruRotUnflipped labels{i} '.mat'];
    
    if ~exist(path, 'file')
        continue
    end
    if ~strcmp(tblAnalysis.consensus(i), 'empty')
        continue
    end
    
    I = load(path);
    I = I.croppedVideo(:,:,1);
    action = selectRotation(I);
    tblAnalysis{i, k} = {action};
    
    tblAnalysis.consensus{i} = char(determineConsensus(categorical(tblAnalysis{i, 2:k})));
    tblAnalysis.consensus2{i} = tblAnalysis.consensus{i};
    
    writetable(tblAnalysis, [settings.inTables,'flipAPDV.xlsx'],'WriteRowNames', true);
end

function consensus = determineConsensus(catList)
% Minimum number of trials is 3
if length(catList) < 3
    consensus = categorical({'empty'});
    return
end
% If 3 or more trials identical, then accept the classification
if length(unique(catList)) == 1
    consensus = catList(1);
    return
end

[uniqueList, count] = mode(catList);
% Accept classification if more than half of the trials agree and more trials than 3
if count > (length(catList) - count) && length(catList) > 3
    consensus = uniqueList;
    return
end
% Give up after 7 attempts
if length(catList) > 6
    consensus = categorical({'undetermined'});
    return
end
% Otherwise keep trying
consensus = categorical({'empty'});
end

function flag = testConsensus()
    test{1} = categorical({'flip AP', 'flip AP'});
    test{2} = categorical({'flip AP', 'flip AP', 'flip AP'});
    test{3} = categorical({'flip AP', 'flip AP', 'flip DV'});
    test{4} = categorical({'flip AP', 'flip AP', 'flip DV', 'flip DV', 'flip AP'});
    test{5} = categorical({'flip AP', 'flip AP', 'flip DV', 'flip DV', 'rotate 180', 'rotate 180'});
    test{6} = categorical({'flip AP', 'flip AP', 'flip DV', 'flip DV', 'rotate 180', 'no flip', 'no flip'});
    
    for i = 1:length(test)
        result(i) = determineConsensus(test{i});
    end
    
    answers = categorical({'empty', 'flip AP', 'empty', 'flip AP', 'empty', 'undetermined'});
    
    flag = all(result == answers);
end

%% Determine which ones to flip
% PB1 = categorical(tblAnalysis.PB1);
% PB2 = categorical(tblAnalysis.PB2);
% PB3 = categorical(tblAnalysis.PB3);
% PB4 = categorical(tblAnalysis.PB4);
% PB5 = categorical(tblAnalysis.PB5);
% PB6 = categorical(tblAnalysis.PB6);
% PB7 = categorical(tblAnalysis.PB7);
% PBaction = [PB1, PB2, PB3, PB4, PB5, PB6, PB7];
% [action, F] = mode(PBaction, 2);
% action(action == categorical({'skip'})) = PB1(action == categorical({'skip'}));
% tblAnalysis.consensus = action;
end

function action = selectRotation(I)
actionLegend = {'no flip', 'flip AP', 'flip DV', 'rotate 180'};

image{1} = I;
image{2} = flipud(image{1});
image{3} = fliplr(image{1});
image{4} = rot90(image{1},2);

randIdx = randperm(4);

annotation = [image{randIdx(1:2)}; image{randIdx(3:4)}];
colormap('gray')
imagesc(annotation)

[x, y, b] = ginput(1);
[Y, X, ~] = size(image{1});

if x <= X && y <= Y
    quadrantNumber = 1;
elseif x > X && y <= Y
    quadrantNumber = 2;
elseif x <= X && y > Y
    quadrantNumber = 3;
else
    quadrantNumber = 4;
end

selectedImage = randIdx(quadrantNumber);
action = actionLegend{selectedImage};
end