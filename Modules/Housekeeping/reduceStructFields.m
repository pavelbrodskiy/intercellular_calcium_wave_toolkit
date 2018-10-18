% Eliminates structure fields except for the specified ones. 

function newStruct = reduceStructFields(struct, fieldsToKeep)
f = fieldnames(struct(1));
toRemove = f(~ismember(f,fieldsToKeep));
newStruct = rmfield(struct, toRemove);
end

