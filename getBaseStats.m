%% getBaseStats returns the base stats specified by fName
function stats = getBaseStats(statsBase, fName)

    idx = strcmp(statsBase.OutFiles, [fName '.SFunc.outb']);
    stats = statsBase;
    
    % Extract the relevant stats
    % Note: the Freq and ChanName fields do not scale with Cases
    stats.OutFiles = stats.OutFiles(idx,:);
    stats.Max = stats.Max(idx,:);
    stats.Std = stats.Std(idx,:);
    stats.Mean = stats.Mean(idx,:);
    stats.Trvl = stats.Trvl(idx,:);
    stats.Spec = stats.Spec(idx,:);
    
end