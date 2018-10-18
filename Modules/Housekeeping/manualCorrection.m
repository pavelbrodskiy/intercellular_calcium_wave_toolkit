function manualCorrection(settings, flipLR, flipUD, reannotate)
%% Flip discs left/right
for i = 1:length(flipLR)
    disp(['Manually flipping L/R: ' flipLR{i}])
    load([settings.thruRot flipLR{i} '.mat'], 'croppedVideo');
    croppedVideo = fliplr(croppedVideo);
    save([settings.thruRot flipLR{i} '.mat'], 'croppedVideo');
    
    if exist([settings.thruMask flipLR{i} '.mat'], 'file')
        load([settings.thruMask flipLR{i} '.mat'], 'rotMask');
        rotMask = fliplr(rotMask);
        save([settings.thruMask flipLR{i} '.mat'], 'rotMask');
    end
    
    if exist([settings.thruAxes flipLR{i} '.mat'], 'file')
        load([settings.thruAxes flipLR{i} '.mat'], 'AP', 'DV');
        [Y, X, T] = size(croppedVideo);
        AP(1,:) = X - AP(1,:) + 1;
        DV(1,:) = X - DV(1,:) + 1;
        save([settings.thruAxes flipLR{i} '.mat'], 'AP', 'DV', '-append');
    end
end

%% Flip discs up/down
for i = 1:length(flipUD)
    disp(['Manually flipping U/D: ' flipUD{i}])
    load([settings.thruRot flipUD{i} '.mat'], 'croppedVideo');
    croppedVideo = flipud(croppedVideo);
    save([settings.thruRot flipUD{i} '.mat'], 'croppedVideo');
    
    if exist([settings.thruMask flipUD{i} '.mat'], 'file')
        load([settings.thruMask flipUD{i} '.mat'], 'rotMask');
        rotMask = flipud(rotMask);
        save([settings.thruMask flipUD{i} '.mat'], 'rotMask');
    end
    
    if exist([settings.thruAxes flipUD{i} '.mat'], 'file')
        load([settings.thruAxes flipUD{i} '.mat'], 'AP', 'DV');
        [Y, X, T] = size(croppedVideo);
        AP(1,:) = Y - AP(2,:) + 1;
        DV(1,:) = Y - DV(2,:) + 1;
        save([settings.thruAxes flipUD{i} '.mat'], 'AP', 'DV', '-append');
    end
end

%% Remove annotations from poorly-annotated discs
for i = 1:length(reannotate)
    disp(['Manually flipping L/R: ' reannotate{i}])
    
    if exist([settings.thruMask flipLR{i} '.mat'], 'file')
        delete([settings.thruMask flipLR{i} '.mat']);
    end
    
    if exist([settings.thruAxes flipLR{i} '.mat'], 'file')
        delete([settings.thruAxes flipLR{i} '.mat']);
    end
end
