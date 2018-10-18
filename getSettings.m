% This function creates the settings structure used in the rest of the
% analysis tools. This makes it easier to keep track of all of the input
% and output files, as well as throughput data that is generated once and
% used many times.

function settings = getSettings()
%% Get root directories
[activeDir, ~, ~] = fileparts(mfilename('fullpath'));
settings.activeDir = [activeDir filesep];
settings.rootData = [activeDir filesep 'dataProcessing' filesep];
settings.output = [activeDir filesep 'Output' filesep];
settings.outMP4 = [activeDir filesep 'MP4' filesep];

%% Get input directories
settings.inExperimentalData = [settings.activeDir 'Data' filesep 'gfp' filesep];
settings.inRFP = [settings.activeDir 'Data' filesep 'rfp' filesep];
%settings.inLowMag = [settings.activeDir 'RawTiffStacks' filesep 'WholeDiscImages' filesep];
settings.inTables = [settings.activeDir 'Inputs' filesep];
settings.labelTabel = [settings.inTables 'labelTabel.xlsx'];
settings.rejectTabel = [settings.inTables 'labelReject.xlsx'];
settings.qualitativeTabel = [settings.inTables 'qualitativeScoring.xlsx'];
settings.flutterTabel = [settings.inTables 'fluttering.xlsx'];
settings.projectTable = [settings.inTables 'ZProject.xlsx'];
settings.projectTiffInput = [settings.activeDir 'RawTiffStacks' filesep 'ZStacks' filesep];
settings.projectTiffOutput = [settings.activeDir 'RawTiffStacks' filesep 'ZProjected' filesep];

%% Get throughput directories
settings.thruTime = [settings.rootData 'tempTime' filesep];
settings.thruStats = [settings.rootData 'tempStatistics' filesep];
settings.thruPSD = [settings.rootData 'tempPSD' filesep];
settings.thruMaskUnflipped = [settings.rootData 'tempMasksUnflipped' filesep]; 
settings.thruMask = [settings.rootData 'tempMasks' filesep]; %store the final mask after orientation correct
settings.thruAxes = [settings.rootData 'tempAxes' filesep];
settings.thruRotUnflipped = [settings.rootData 'tempRotUnflipped' filesep];
settings.thruRot = [settings.rootData 'tempRotated' filesep]; %store the final video after orientation correction
settings.thruRawMask = [settings.rootData 'tempRawMasks' filesep];
settings.thruRotRFP = [settings.rootData 'tempRotRFP' filesep];
settings.thruRotNormalized = [settings.rootData 'tempRotNormalized' filesep];
settings.thruRotRFPFlipped = [settings.rootData 'tempRotRFPFlipped' filesep];
settings.thruRotNormalizedFlipped = [settings.rootData 'tempRotNormalizedFlipped' filesep];
settings.outArchive = [settings.rootData 'archive' filesep];
settings.matProfiles = [settings.rootData 'tempProfiles.mat'];
settings.matMasks = [settings.rootData 'tempManualMasks.mat'];
settings.tmp = [settings.rootData 'tmp' filesep];
settings.thruGeometry = [settings.rootData 'tempGeometry' filesep];

%% Get output directories
settings.outRough = settings.output;
settings.outFinal = [activeDir filesep 'PaperFigures' filesep];

%% Get dependency directories
settings.depExt = [settings.activeDir 'Dependencies' filesep];
settings.depInt = [settings.activeDir 'Modules' filesep];

%% Add dependancy folders to path
addpath(genpath(settings.depExt))
addpath(genpath(settings.depInt))

%% Generate unique identifier for analysis
currentTime = now();
timeString = datestr(currentTime);
settings.uniqueIdentifier = strrep(timeString,':','-');

%% Set analysis settings
settings.analysis.binSize = 4;          % Size of spatial bins in pixels
settings.sizeStandard = 1;              % Standard scale of output images (pix in/pix out)
settings.force = false;                 % Set true to rerun completed analysis
settings.scale.x20 = 0.7009;            % Scale of 20x objective (px/um)
settings.minTime = 120;                 % Minimum time for analysis (frames)
settings.maxTime = 361;
settings.timestep = 10;

%% Bar graph settings
settings.pIN.controlLabel = 'control';
settings.pIN.textAngle = 90;
settings.pIN.signifiganceCutoffs = [0.05, 0.01, 0.005];
settings.pIN.colorList = {'black','red','blue','green','magenta','cyan','yellow'};
settings.pIN.normalize = false;
settings.pIN.tTest = true;
settings.pIN.reSort = false;
settings.pIN.supercategories = [];
settings.pIN.listN = true;

%% Set feature extraction parameters
x = [0.316, 10.0, 22.7, 7.99, 764];
settings.dFoverFType = 'GaussianBandpass';
settings.minAmplitude = x(1);
settings.minPeriod = x(2);
settings.minPeakWidth = x(3);
settings.tau = x(4:5);

%% Set pouch boundaries for compartments and regions
settings.AP = [0.0, 0.6, 1.0];
settings.AP = [0.0, 0.5, 0.6, 1.0];
settings.DV = [0.0, 1.0];
settings.stripWidth = 0.1;

%% Default color maps for figures
settings.maxMapIntensity = 0.9;

settings.colorMap.amp       = makeCMap('hot*');
settings.colorMap.freq      = makeCMap('bone*');
settings.colorMap.WHM       = makeCMap('copper*');
settings.colorMap.dtyCyc    = parula(255);
settings.colorMap.basal     = makeCMap('dusk*');

maps = settings.colorMap;
settings.mapOrder = {maps.amp, maps.freq, maps.WHM, maps.basal, maps.dtyCyc, maps.dtyCyc, maps.dtyCyc, maps.dtyCyc, maps.dtyCyc, maps.dtyCyc, maps.dtyCyc, maps.dtyCyc, maps.dtyCyc, maps.dtyCyc, maps.dtyCyc};
settings.histBins = 500;

%% Field names for analysis
%settings.fieldNames = {'AmpNorm','PeakRate','WHM','Basal'};%,'Integral'};
settings.fieldNames = {'AmpNorm','PeakRate','WHM','Basal','RFP_basal_min','RFP_basal_mean','RFP_integrated','RFP_mean_single_channel','AmpRFP'};
settings.fieldLabels = {'Amplitude (\DeltaI/I)','Frequency (mHz)','WHM (s)','Basal Level (au)'};%,'Integral (s\DeltaI/I)'};
settings.fieldLabelsTwoRow = {{'Amplitude','(\DeltaI/I)'},{'Frequency','(mHz)'},{'WHM','(s)'},{'Basal', 'Level (au)'}};%,{'Integral', '(s\DeltaI/I)'}};
settings.fieldLog = [false, false, false, false, false];
%settings.cutoffs = {[0,1.4],[0, 4.2],[0,150],[210, 1500], [0, 3e5]};
settings.cutoffs = {[0,1.4],[0, 4.2],[0,150],[210, 1500], [0, 3e5], [], [], []};
settings.controlSizeBins = [-inf, 14, 16, 19, inf]*10^3;

%% Composite generation
settings.maskPoints =  60; %600;
settings.simplifyTolMask = 0.5;
settings.simplifyTolAxis = 0.5;
settings.meridians = 30; %300;
settings.extrapDistance = 15;

%% Qualitative analysis settings
settings.ignoreCats = categorical({'unknown','unusable','unusable1'});

%% Declare input parser





% addOptional(p,'height',defaultHeight,@isnumeric);
% addParameter(p,'units',defaultUnits);
% addParameter(p,'shape',defaultShape,...
%     @(x) any(validatestring(x,expectedShapes)));

end