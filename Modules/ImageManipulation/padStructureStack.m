% Input a cell array of structures. For each field, find max dimensions 
% and pad each element to size, then return a cell array of structures with
% padded fields.

function padded = padStructureStack(unpadded)
fields = fieldnames(unpadded);

for i = 1:length(fields)
    paddedFieldStack = padStack({unpadded.(fields{i})});
    paddedField{i} = cell2struct(paddedFieldStack, {fields{i}}, length(paddedFieldStack));
end

padded = catstruct(paddedField{:});

end

