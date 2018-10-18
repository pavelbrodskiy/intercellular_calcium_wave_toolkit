function normPSD = normSpectra(PSDs)

PSDintegral = mean(PSDs, 2);
normPSD = mean(PSDintegral) * PSDs ./ repmat(PSDintegral, [1, size(PSDs, 2), size(PSDs, 3)]);

end

