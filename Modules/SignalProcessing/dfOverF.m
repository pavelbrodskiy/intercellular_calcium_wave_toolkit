% Signal filtering. Input signal, output aproximate Ca2+ concentration
% normalized to baseline.
% [dF_overF, F_0, F_bar, tau] = dfOverF(F, settings)
% [dF_overF, F_0, F_bar, tau] = dfOverF(F, tau1, tau2, tau3, type)
function [dF_overF, F_0, F_bar, tau] = dfOverF(F, varargin)
%% Parse inputs
F = double(F);
if isstruct(varargin{1})
    settings = varargin{1};
    
    timestep = 10;
    tauStep = settings.tau;
    type = settings.dFoverFType;
else
    tauStep = varargin{1};
    timestep = varargin{2};
    if nargin < 4
        type = 'Conventional';
    else
        type = varargin{3};
    end
end

[X, Y, Z] = size(F);

if Z > 1
    if nargin < 5
        settings = getSettings();
    end
    lowSigma = tauStep(1) / timestep;
    highSigma = tauStep(2) / timestep;
    spatialSigma = settings.analysis.binSize;
    
    video = double(F);
    for t = size(video,3):-1:1
        video(:,:,t) = imgaussian(video(:,:,t), spatialSigma);
    end
    
    for i = size(video, 1):-1:1
        for j = size(video, 2):-1:1
            video_0(i,j,:) = imgaussian(video(i,j,:), highSigma);
            video_bar(i,j,:) = imgaussian(video(i,j,:), lowSigma);
        end
    end
    
    dF_overF = (video_bar - video_0) ./ video_0;
    
else
    switch type
        case 'GaussianBandpass'
            F(isnan(F)) = [];
            
            lowSigma = tauStep(1) / timestep;
            highSigma = tauStep(2) / timestep;
            
            F_0 = imgaussian(F, highSigma);
            F_bar = imgaussian(F, lowSigma);
            
            dF_overF = (F_bar - F_0) ./ F_0;
        case 'Conventional'
            %% Gaussian filter (smoothed F)
            F_bar = imgaussian(F, tauStep(2));
            
            %% Min filter (baseline)
            F_0 = imerode(F, true(round(tauStep(3) / 10),1));
            
            %% Calculate dF/F
            dF_overF = ((F_bar-F_0) ./ F_0)';
            
        case 'Exponential'
            %% Apply exponentially-weighted moving average
            dF_overF = tsmovavg(R,'e',tauStep(1));
            
            dF_overF(isnan(dF_overF)) = R(isnan(dF_overF));
            
            if nargin > 2 && nargout > 3
                tau = tauStep / timestep;
            end
    end
end
end

