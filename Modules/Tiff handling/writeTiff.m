function writeTiff( video, filename )
imwrite(uint16(video(:,:,1)), filename)
for k = 2:size(video,3)
    imwrite(uint16(video(:,:,k)), filename, 'writemode', 'append');
end
end

