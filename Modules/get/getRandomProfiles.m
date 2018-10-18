% Returns a matrix where the rows are different bins and the columns are
% timepoints. Gets all of the profiles.

function profiles = getRandomProfiles(n, settings)

if ~exist(settings.matProfiles, 'file')
    getAllProfiles(settings)
end
load(settings.matProfiles, 'intensityProfiles')
idx = round(rand ([1, n]) * size(intensityProfiles, 1));

profiles = intensityProfiles(idx,:);

end

