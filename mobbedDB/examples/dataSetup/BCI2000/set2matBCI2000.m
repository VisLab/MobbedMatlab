%% Convert the 109-subject BCI2000 data set from .edf to .set
%
% Parameters:
%   inDir    directory with .edf data organized by subject
%   outDir   directory of .set data organized by subject
%
%
%
function set2MatBci2000(inDir, outDir)
% Set up the directories
if ~exist(inDir, 'dir')
    error('set2matBCI2000:NoDirectory', '%s doesn''t exist', inDir);
end
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

for s = 1:109  %Process the subjects
    subject = sprintf('S%03d',s);
    fprintf('Subject: %s:\n', subject);
    inFolder = [inDir filesep subject filesep];
    outFolder = [outDir filesep subject];
    if ~exist(inFolder, 'dir')
        warning('set2matBCI2000:MissingSubject', ...
            '%s doesn''t exist', inFolder);
        continue;
    elseif ~exist(outFolder, 'dir')
        mkdir(outFolder);
    end
       
    for t = 1:14 % Process the 14 trials for each subject
        trial = sprintf('R%02d', t);
        inFile = [subject trial '.set'];
        EEG = pop_loadset('filename', inFile, ...
                          'filepath', inFolder); %#ok<NASGU>
        fullFile = [inFolder inFile];
        fprintf('Trial: %s\n', fullFile);
        if ~exist(fullFile, 'file')
            warning('set2matBCI2000:MissingTrial', ...
                '%s doesn''t exist', inFile);
            continue;
        end
        outFile = [outFolder filesep subject trial '.mat'];
        save(outFile, 'EEG');
    end
end
    
