%% Convert the Attention shift from .set to .mat
%
% Parameters:
%   inDir    directory with .set and .edf data 
%   outDir   directory of .mat data 
%   numFiles (output)  number of files converted
%
function numFiles = set2MatAttentionShift(inDir, outDir)
% Set up the directories
if ~exist(inDir, 'dir')
    error('set2matAttentionShift:NoDirectory', '%s doesn''t exist', inDir);
end
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

files = dir(inDir);
files = {files.name};
positions = regexp(files, '[.]*set', 'start');
inFolder = [inDir filesep];
numFiles = length(positions);
for k = 1:length(positions)
    if isempty(positions{k})
        continue;
    end
    outFile = strrep(files{k}, '.set', '.mat');
    EEG = pop_loadset('filename', files{k}, 'filepath', inFolder); %#ok<NASGU>
    save([outDir filesep outFile], 'EEG');
end
    
