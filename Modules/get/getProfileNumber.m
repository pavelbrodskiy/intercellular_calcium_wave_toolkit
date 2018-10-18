function [profileNum] = getProfileNumber(structMaps)
for i = 1:length(structMaps)
   tmpMap = structMaps(i).Basal;
   profileNum(i) = sum(sum(~isnan(tmpMap)));
end