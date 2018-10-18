% Takes an array of values, and determines which values correspond to which
% bin. For example: bin 1 is from cutoffs(1) to cutoffs(2). Values outside
% of bins can be optionally returned.

function identity = binByCutoffs(values, cutoffs)
identity

for i = 1:length(values)
    identity(i) = sum(controlMaskSize(i) > middleCutoffs) + 1;
end

end