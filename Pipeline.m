% Dharsan Soundarrajan
% Ca2+ spatial maps 
% 10/31/2018

%% Clear the workspace
clearvars
close all
settings = prepareWorkspace();

%% Obtain list of lebls for the videos you want to process. 
catList = tableToCategories({'DKS'}, settings)';

%% Extract statistics 
dataTable = getDatatable(settings, catList);

%% Make Spatial maps
settings.outRough = [settings.outFinal 'Figure3_Composites' filesep];
mkdir(settings.outRough);
settings.fieldNames = {'AmpNorm','PeakRate','median_I','dfOverF_integrated_one_channel','median_I_trap'};
mapCutoffs3 = imgStats(settings, dataTable.statsArray, dataTable.coords, dataTable.category, unique(dataTable.category)', dataTable.geometries, [-inf, inf], dataTable.pouchSizes)