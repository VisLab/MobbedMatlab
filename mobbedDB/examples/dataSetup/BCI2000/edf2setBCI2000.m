%% Convert the 109-subject BCI2000 data set from .edf to .set
%
% Parameters:
%   inDir    directory with .edf data organized by subject
%   outDir   directory of .set data organized by subject
%
%
%
function edf2setBCI2000(inDir, outDir)
% Set up the directories
if ~exist(inDir, 'dir')
    error('edf2setBCI2000:NoDirectory', '%s doesn''t exist', inDir);
end
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

chanlocs = readlocs('eeg64BCI2000.loc');

for s = 1:109  %Process the subjects
    subject = sprintf('S%03d',s);
    inFolder = [inDir filesep subject];
    outFolder = [outDir filesep subject];
    if ~exist(inFolder, 'dir')
        warning('edf2setBCI2000:MissingSubject', ...
            '%s doesn''t exist', inFolder);
        continue;
    elseif ~exist(outFolder, 'dir')
        mkdir(outFolder);
    end
    
    
    for t = 1:14 % Process the 14 trials for each subject
        trial = sprintf('R%02d', t);
        inFile = [inFolder filesep subject trial '.edf'];
        fprintf('Trial: %s\n', inFile);
        eName = eventName(t);
        if ~exist(inFile, 'file')
            warning('edf2setBCI2000:MissingTrial', ...
                '%s doesn''t exist', inFile);
            continue;
        end
        outFile = [outFolder filesep subject trial '.set'];
        EEG = k_pop_biosig(inFile);		% call revised pop_biosig
        EEG.chanlocs = chanlocs;
        for e = 1:length(EEG.event)
            EEG.event(e).type = [eName EEG.event(e).type];
        end
        
        pop_saveset(EEG, 'filename', outFile, 'savemode', 'onefile');
    end
end

function eName = eventName(trial)
    switch trial
        case 1   
            eName = 'BASE1';
        case 2    
            eName = 'BASE2';
        case {3, 7, 11}
            eName = 'TASK1';
        case {4, 8, 12}
            eName = 'TASK2';
        case {5, 9, 13} 
            eName = 'TASK3';
        case {6, 10, 14}
            eName = 'TASK4';
        otherwise
            eName = 'UNKNOWN';
    end
        
    
