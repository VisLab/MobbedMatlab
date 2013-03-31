function [fPaths, tElapsed] = getFileList(inDir)
% Get a list of the files in a directory tree
%
% Parameters:
%    inDir        Directory with attention shift as .mat files
%    fpaths       (output) Full pathnames of the files in this directory
%
    tStart = tic;
    fPaths = {};
    directories = {inDir};
    while ~isempty(directories)
        nextDir = directories{end};
        files = dir(nextDir);
        fileNames = {files.name}';
        fileDirs = cell2mat({files.isdir}');
        compareIndex = ~strcmp(fileNames, '.') & ~strcmp(fileNames, '..');
        subDirs = strcat([nextDir filesep], fileNames(compareIndex & fileDirs));
        fileNames = strcat([nextDir filesep], fileNames(compareIndex & ~fileDirs));    
        directories = [directories(1:end-1); subDirs(:)];
        fPaths = [fPaths(:); fileNames(:)];
    end
    tElapsed = toc(tStart);
end % getFileList
