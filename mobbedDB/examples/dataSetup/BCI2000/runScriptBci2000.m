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

% %% EDF to SET conversion for the BCI2000 directory tree
% indir = 'H:\BCIProcessing\BCI2000Original';   % Root directory of .edf data
% outdir = 'H:\BCIProcessing\BCI2000Set';       % Root directory for output
% tic
% edf2SetBci2000(indir, outdir);                % Root directory 
% toc
%% SET to MAT conversion for the BCI2000 directory tree
inDir = 'H:\BCIProcessing\BCI2000Set';         % 
outDir = 'H:\BCIProcessing\BCI2000Mat';
tStart = tic;
numFiles = set2MatBci2000(inDir, outDir);
tElapsed = toc(tStart);
fprintf('BCI 2000 .set to .mat files: total (%gs), average (%gs), number of files (%g)\n', ...
    tElapsed, tElapsed/numFiles, numFiles);

%% Assessing the size of the collection
inDir = 'H:\BCIProcessing\BCI2000Mat'; 
[numFiles, frames, events, channels, eAttributes] = countAttentionShift(inDir);
fprintf('Bci2000 collection:\n')
fprintf('Number of files = %g\n', numFiles);
fprintf('Average number of frames = %g\n', frames);
fprintf('Average number of events = %g\n', events);
fprintf('Average number of channels = %g\n', channels);
fprintf('Average number of attributes/event = %g\n', eAttributes);

%% Clean the data using Faster
%% Timing of loading .mat files
inDir = 'H:\BCIProcessing\BCI2000Mat';
outDir = 'H:\BCIProcessing\BCI2000Clean';
tStart = tic;
numFiles = cleanFaster(inDir, outDir);
tElapsed = toc(tStart);
fprintf('Load .mat files: total (%g), average (%g) number of files (%g)\n', ...
    tElapsed, tElapsed/numFiles, numFiles);

%% Write entire BCI2000 repository to a database
%% Create database if it doesn't exist
    try
      Mobbed.createdb('bci2000db', 'localhost', 'postgres', 'admin', 'mobbed.xml')
    catch ME   % If database already exists, creation fails and warns
        warning('mobbed:creationFailed', ME.message);
    end
    
%% Open a connection the database,store the data not exploded, close  
DB = Mobbed('bci2000db', 'localhost', 'postgres', 'admin');
inDir = 'H:\BCIProcessing\BCI2000Mat';

%% Store the bci2000 data
tStart = tic;
[fUUIDs, uniqueEvents] = storeDb(DB, inDir, 'eeg', 'BCI2000', true);
tElapsed = toc(tStart);
fprintf('Storing bci2000: total time: %g s, average time: %g s\n', ...
    tElapsed, tElapsed/length(fUUIDs));
fprintf('                         number of datasets: %g, number of unique events: %g\n', ...
    length(fUUIDs), length(uniqueEvents));
%% Timing of loading .mat files
inDir = 'H:\BCIProcessing\BCI2000Mat';
tStart = tic;
numFiles = loadMat(inDir);
tElapsed = toc(tStart);
fprintf('Load .mat files: total (%g), average (%g) number of files (%g)\n', ...
    tElapsed, tElapsed/numFiles, numFiles);

 %% Assessing the size of the collection

inDir = 'H:\BCIProcessing\BCI2000Mat';
[numFiles, frames, events, channels, eAttributes] = bci2000Count(inDir);
fprintf('Count collection:\n')
fprintf('Number of files = %g\n', numFiles);
fprintf('Average number of frames = %g\n', frames);
fprintf('Average number of events = %g\n', events);
fprintf('Average number of channels = %g\n', channels);
fprintf('Average number of attributes/event = %g\n', eAttributes);
