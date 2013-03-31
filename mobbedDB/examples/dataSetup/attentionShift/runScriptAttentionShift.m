%% BCI 2000 processing scripts
%
% These scripts assume that you have downloaded the entire 109-subject
% BCI2000 collection, preserving the directory structure of the data
% from physionet.
%
% The processing steps
%  1)  Convert the entire directory from .edf format to EEGLAB .set format,
%      in a new directory tree with the same structure as original
%  2)  Save the .set files as .mat files in another directory tree
%  3)  Write the data to the database
%  4)  


%% SET to MAT conversion for the Attention Shift data
inDir = 'G:\NeuroErgonomicsData\AttentionShift\AttentionShiftOriginal';         % 
outDir = 'G:\NeuroErgonomicsData\AttentionShift\AttentionShiftMat'; 
tStart = tic;
numFiles = set2MatAttentionShift(inDir, outDir);
tElapsed = toc(tStart);
fprintf('Attention shift .set to .mat files: total (%gs), average (%gs), number of files (%g)\n', ...
    tElapsed, tElapsed/numFiles, numFiles);
%% Time to load the AttentionShift data       % 
inDir = 'G:\NeuroErgonomicsData\AttentionShift\AttentionShiftMat'; 
tStart = tic;
numFiles = loadMat(inDir);
tElapsed = toc(tStart);
fprintf('Attention shift load .mat files: total (%gs), average (%gs), number of files (%g)\n', ...
    tElapsed, tElapsed/numFiles, numFiles);

%% Assessing the size of the collection
inDir = 'G:\NeuroErgonomicsData\AttentionShift\AttentionShiftMat'; 
[numFiles, frames, events, channels, eAttributes] = countEEG(inDir);
fprintf('Attention shift collection:\n')
fprintf('Number of files = %g\n', numFiles);
fprintf('Average number of frames = %g\n', frames);
fprintf('Average number of events = %g\n', events);
fprintf('Average number of channels = %g\n', channels);
fprintf('Average number of attributes/event = %g\n', eAttributes);

%% Write entire AttentionShift repository to a database
%% Create database if it doesn't exist
try
  Mobbed.createdb('attention', 'localhost', 'postgres', 'admin', 'mobbed.xml')
catch ME   % If database already exists, creation fails and warns
    warning('mobbed:creationFailed', ME.message);
end

%% Open a connection the database  
DB = Mobbed('attention', 'localhost','postgres', 'admin');
inDir = 'G:\NeuroErgonomicsData\AttentionShift\AttentionShiftMat';
DB.Verbose = false;

%% Store the attention shift data
tStart = tic;
[fUUIDs, uniqueEvents] = storeDb(DB, inDir, 'eeg', 'Attention shift dataset', true);
tElapsed = toc(tStart);
fprintf('Storing attention shift: total time: %g s, average time: %g s\n', ...
    tElapsed, tElapsed/length(fUUIDs));
fprintf('                         number of datasets: %g, number of unique events: %g\n', ...
    length(fUUIDs), length(uniqueEvents));
