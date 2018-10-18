function stackedProfiles = stackProfiles(I, h)
I = I(end:-1:1,:);
means = mean(I,2);
vertDisplacement = ((0:h:(h*(size(I, 1)-1)))' - means);

stackedProfiles = I';
for i = 1:size(stackedProfiles, 2)
    stackedProfiles(:,i) = stackedProfiles(:,i) + repmat(vertDisplacement(i), [size(stackedProfiles, 1), 1]);
end

end

