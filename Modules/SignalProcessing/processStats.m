function [statMat, names] = processStats(stats)
    names = fieldnames(stats); 
    figure
    for i = 1:length(names)
        subplot(3,3,i)
        tmp = [stats.(names{i})];
        hist(tmp(:),100);
        xlabel(names{i});
        statMat(i,:) = tmp;
    end
end

