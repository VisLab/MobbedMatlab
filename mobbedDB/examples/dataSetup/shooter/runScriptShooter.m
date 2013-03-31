%% Shooter dataset processing scripts
%
% These scripts assume that you have shooter dataset stored in a 
% single directory tree with the set files for each subject in a 
% separate subdirectory.
%
% The processing steps
%  1)  Convert the entire directory from .edf format to EEGLAB .set format,
%      in a new directory tree with the same structure as original
%  2)  Save the .set files as .mat files in another directory tree
%  3)  Write the data to the database
%  4)  


%% SET to MAT conversion for the shooter data
inDir = 'G:\NeuroErgonomicsData\Shooter\ShooterSet';         % 
outDir = 'G:\NeuroErgonomicsData\Shooter\ShooterMat'; 
tStart = tic;
numFiles = set2MatShooter(inDir, outDir);
tElapsed = toc(tStart);
fprintf('Shooter .set to .mat files: total (%gs), average (%gs), number of files (%g)\n', ...
    tElapsed, tElapsed/numFiles, numFiles);

%% Time to load the shooter data       % 
inDir = 'G:\NeuroErgonomicsData\Shooter\ShooterMat';  
tStart = tic;
numFiles = loadMat(inDir);
tElapsed = toc(tStart);
fprintf('Shooter load .mat files: total (%g), average (%g) number of files (%g)\n', ...
    tElapsed, tElapsed/numFiles, numFiles);

%% Assessing the size of the collection
inDir = 'G:\NeuroErgonomicsData\Shooter\ShooterMat'; 
[numFiles, frames, events, channels, eAttributes] = countEEG(inDir);
fprintf('Shooter collection:\n')
fprintf('Number of files = %g\n', numFiles);
fprintf('Average number of frames = %g\n', frames);
fprintf('Average number of events = %g\n', events);
fprintf('Average number of channels = %g\n', channels);
fprintf('Average number of attributes/event = %g\n', eAttributes);

%% Write entire shooter repository to a database
%% Create database if it doesn't exist
try
  Mobbed.createdb('shooter', 'localhost', 'postgres', 'admin', ... 
      'mobbed.xml')
catch ME   % If database already exists, creation fails and warns
    warning('mobbed:creationFailed', ME.message);
end

%% Open a connection the database  
DB = Mobbed('shooter', 'localhost','postgres', 'admin');
inDir = 'G:\NeuroErgonomicsData\Shooter\ShooterMat'; 

%% Store the shooter data (unexploded)
tStart = tic;
[fUUIDs, uniqueEvents] = storeDb(DB, inDir, 'eeg', 'Shooter dataset', true);
tElapsed = toc(tStart);
numFiles = length(fUUIDs(:));
fprintf('Shooter: total store time: %g s, average store time: %g s\n', ...
    tElapsed, tElapsed/numFiles);
fprintf('         number of datasets: %g, number of unique events: %g\n', ...
    numFiles, length(uniqueEvents));
close(DB);

%% Load the shooter data (unreconstructed)
tStart = tic;
fUUIDs = loadDb(DB, false);
tElapsed = toc(tStart);
numFiles = length(fUUIDs(:));
fprintf('Shooter: total load time: %g s, average load time: %g s\n', ...
    tElapsed, tElapsed/numFiles);
fprintf('         number of datasets: %g\n', numFiles);