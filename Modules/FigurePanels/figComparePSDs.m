% This figure-generation method compares composited PSDs for different
% conditions.

function metadata = figComparePSDs(settings, labels, category, specificCats)
%% Declare parameters (Lazy)
if nargin < 3
    category = categorical(ones(size(labels)));
end
if nargin < 4
    specificCats = unique(category);
else
    specificCats = unique(specificCats);
end

M = 2;
N = 2;

if M*N < length(specificCats)
    M = ceil(sqrt(length(specificCats)));
    N = ceil(sqrt(length(specificCats)));
end

%% Find frequency axis
n = 2048;
dt = 10;
fs = 1/dt;
freq = 1e3*fs*(0:n/2)/n;

%% Get PSDs for relevant labels
figure
for i = 1:length(specificCats);
    subplot(M,N,i)
    cellPSD = getPSD(labels(category == specificCats(i)), settings);
    [medPSD, ci] = compositeSpectra(cellPSD, category);
    shadedErrorBar(freq,medPSD,ci)
    
    title(char(specificCats(i)));
    xlabel('Frequency (mHz)')
    ylabel('Power (au)')
    axis([0,10,0,1e6]);
    
    drawnow
end

metadata = [];
