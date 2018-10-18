function [result, flag] = searchFields(structure, searchTerm)
fields = fieldnames(structure);

activeFields = find(cellfun(@(s) ~isempty(strfind(s, searchTerm)), fields));

result = nan(1, length(structure));

for i = 1:length(activeFields)
    resultTmp = {structure.(fields{activeFields(i)})};
    clear resultTmpArray
    for j = 1:length(resultTmp)
        tmp2 = resultTmp{j};
        if isnumeric(tmp2)
            resultTmpArray(j) = tmp2;
        elseif isempty(tmp2)
            resultTmpArray(j) = NaN;
        else
            tmp2(~ismember(tmp2,'0':'9')) = '';
            tmp2 = str2num(tmp2);
            resultTmpArray(j) = tmp2;
        end
    end
    
    result(isnan(result)) = resultTmpArray(isnan(result));
end