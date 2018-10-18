function [smoothedRoI] = smoothRoI(RoI)

tempRoI = uint8(zeros(size(RoI(:,:,1))));
tempRoI(RoI > 0) = 255;
smoothedRoI = imgaussfilt(tempRoI,25);
smoothedRoI = smoothedRoI > 127;

end

