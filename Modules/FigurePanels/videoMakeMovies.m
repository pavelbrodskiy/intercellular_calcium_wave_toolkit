function videoMakeMovies(labels, category, settings, mode, catList, name)
mkdir(settings.outMP4);
if nargin < 5
    catList = unique(category);
end
if nargin < 4
    mode = 'rot';
end
if nargin < 6
    name = 'RotatedVideo';
end

%% Make figures
switch mode
    case 'rot'
        for i = length(labels):-1:1
            for j = 1:length(catList)
                if category(i) == catList(j)
                    disp(['Making MP4: ' labels{i}]);
                    filename = [settings.outMP4, name, '_' char(category(i)), ' ', labels{i}];
                    filename = strrep(filename, '?', 'u');
                    filename = strrep(filename, '/', '-');
                    filename = strrep(filename, '>', '-');
                    if ~exist([filename '.mp4'],'file')
                        load([settings.thruRot, labels{i}, '.mat']);
                        load([settings.thruMask, labels{i}, '.mat']);
                        stamped = stampMask(croppedVideo, rotMask);
                        writeMP4(stamped, filename);
                    end
                end
            end
        end
    case 'raw'
        for i = length(labels):-1:1
            for j = 1:length(catList)
                if category(i) == catList(j)
                    disp(['Making MP4: ' labels{i}]);
                    filename = [settings.outMP4, 'raw_' name, '_' char(category(i)), ' ', labels{i}];
                    filename = strrep(filename, '?', 'u');
                    filename = strrep(filename, '/', '-');
                    filename = strrep(filename, '>', '-');
                    if ~exist([filename '.mp4'],'file')
                        video = readTiff([settings.inExperimentalData, labels{i} '.tif']);
                        writeMP4(video, filename);
                    end
                end
            end
        end
    otherwise
        error('Mode must be rot or raw')
end


