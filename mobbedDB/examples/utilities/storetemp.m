% storeTemporary   store a list of files as temporary files
function [names, tElapsed] = storeTemp(fPaths)
tStart = tic;
if ~isempty(fPaths)
    names = cell(length(fPaths));
    for k = 1:length(fPaths)
        x = load(fPaths{k});
        fNames = fieldnames(x);
        EEG = x.(fNames{1});
        names{k} = tempname;
        save names{k} EEG;
    end
else
    names = '';
end
tElapsed = toc(tStart);
end % storeTemporary