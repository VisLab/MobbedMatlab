function numFiles = set2MatShooter(inDir, outDir)
%% Convert the shooter data set  from .set to .mat
%
% Parameters:
%   inDir    directory tree with .set data 
%   outDir   directory tree with .mat data 
%   numFiles (output) number of files converted
%
if ~exist(inDir, 'dir')
    error('shooterSet2Mat:DirectoryMissing', '%s doesn''t exist', inDir);
end
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

directories = dir(inDir);
directoryNames = {directories.name};
compareIndex = ~strcmp(directoryNames, '.') & ~strcmp(directoryNames, '..');
numFiles = 0;
for k = 1:length(directories)
    if ~compareIndex(k) || ~directories(k).isdir
        continue;
    end
    inFolder = [inDir filesep directoryNames{k}];
    files = dir(inFolder);
    outFolder = [outDir filesep directoryNames{k}];
    if ~exist(outFolder, 'dir')
        mkdir(outFolder)
    end
    inFolder = [inFolder filesep]; %#ok<AGROW>
    outFolder = [outFolder filesep]; %#ok<AGROW>
    for j = 1:length(files)
        if files(j).isdir
            continue;
        end
        fileName = files(j).name;
        outFile = strrep(fileName, '.set', '.mat');
        EEG = pop_loadset('filename', fileName, 'filepath', inFolder); %#ok<NASGU>
        save([outFolder outFile], 'EEG');
        numFiles = numFiles + 1;
    end
end
    
