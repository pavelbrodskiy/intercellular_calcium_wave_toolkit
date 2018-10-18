function [metadata debug] = getMetadata(labels, settings)
%% Get list of raw tiff names
for i = 1:length(labels)
    tmp = labels{i};
    idx = strfind(tmp, '1');
    if length(tmp) > 11 && ~isempty(idx)
        filenames{i} = [tmp(idx:11+idx) '.tif'];
    else
        filenames{i} = '';
    end
end

%% Load metadata array
for i = 1:length(filenames)
    disp(['Processing number ' num2str(i) ' of ' num2str(length(filenames))]);
    
    id = [settings.inExperimentalData filenames{i}];
    
    if exist(id)
        status = bfCheckJavaPath(1);
        assert(status, ['Missing Bio-Formats library. Either add bioformats_package.jar '...
            'to the static Java path or add it to the Matlab path.']);
        
        % initialize logging
        javaMethod('enableLogging', 'loci.common.DebugTools', 'INFO');
        
        % Get the channel filler
        r = bfGetReader(id, 0);
        
        globalMetadata = r.getGlobalMetadata();
        
        metadataCellArray{i} = hashtable2struct(globalMetadata);
    else
        metadataCellArray{i} = [];
    end
end

metadata = mergestructs(metadataCellArray);

%% Obtain debug data
if nargout <= 1
    return
end

fields = fieldnames(metadata(1));

for i = 1:length(fields)
    debug.count.(fields{i}) = length({metadata.(fields{i})});
end


end

function struct = hashtable2struct(hashTable)
% This function converts a java hash table into a matlab struct
keys = hashTable.keySet;
keys = keys.toArray;
for i = 1:length(keys)
    tmpKey = keys(i);
    tmpKey(~ismember(tmpKey,['A':'Z' 'a':'z' '0':'9'])) = ' ';
    tmpKey = strtrim(tmpKey);
    tmpKey = strrep(tmpKey, ' ', '_');
    if ismember(tmpKey(1),'0':'9')
        tmpKey = ['n' tmpKey];
    end
    struct.(tmpKey) = hashTable.get(keys(i));
end
end

function structArray = mergestructs(structCellArray, interpretTypes)
% This function takes a cell array of different structs, makes a basic
% struct, and returns an array that has all of the fields of the original
% struct. Empty fields are removed. If interpretTypes is true (default)

% Warning: this code has many bugs and is garbage

if nargin < 2
    interpretTypes = true;
end

emptyStructs = cellfun(@isempty,structCellArray);

baseStruct = catstruct(structCellArray{~emptyStructs});

fields = fieldnames(baseStruct);

if interpretTypes
    numberFields = zeros(1,length(fields),'logical');
    
    for i = 1:length(fields)
        if isnumeric(baseStruct.(fields{i}))
            baseStruct.(fields{i}) = NaN;
            numberFields(i) = 1;
        elseif isempty(str2num(baseStruct.(fields{i})))
            baseStruct.(fields{i}) = '';
        else
            baseStruct.(fields{i}) = NaN;
            numberFields(i) = 1;
        end
    end
end

structArray = repmat(baseStruct, [1, length(structCellArray)]);

for i = find(~emptyStructs)
    structArray(i) = catstruct(structArray(i), structCellArray{i});
end

remove = zeros(1,length(fields),'logical');

for i = 1:length(fields)
    if isempty([structArray.(fields{i})])
        remove(i) = 1;
    end
    if numberFields(i)
        for j = find(~emptyStructs)
            if ~isnumeric(structArray(j).(fields{i}))
                structArray(j).(fields{i}) = str2num(structArray(j).(fields{i}));
            end
        end
    end
end

structArray = rmfield(structArray, fields(remove));

end