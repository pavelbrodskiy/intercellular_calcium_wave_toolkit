% This function keeps only the fields and samples that are relevant to the
% current analysis. catKeep provides the categories to keep, and fieldNames
% provides the fields to keep. By default, all are kept.

function [category, varargout] = cleanDataset(category, catKeep, varargin)

keep = zeros(size(category));
for currentCat = catKeep(:)'
    keep(category == currentCat) = 1;
end

for i = 1:(nargin - 2)
    temp = varargin{i};
    if istable(temp)
        temp(~keep,:) = [];
    else
        temp(~keep) = [];
    end
    varargout{i} = temp;
end

category(~keep) = [];

end

