function catList = tableToCategories(sheet, settings)
catList = [];
for i = 1:length(sheet)
    sheetName = [settings.inTables sheet{i} '.xlsx'];
    [~, labelTabel] = xlsread(sheetName);
    catList = [catList; categorical(labelTabel(:,1))];
end
end

