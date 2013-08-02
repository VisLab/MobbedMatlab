%% Setup for this installation.
dbName = 'dbmobbed';
dbHost = 'localhost';
dbPort = 5432;
dbUser = 'postgres';
dbPassword = 'admin';

%% Accessing the database in MATLAB
DB = Mobbed(dbName, [dbHost ':' num2str(dbPort)], dbUser, dbPassword);

%% Load the data and tag 
load('EEGShoot.mat');
EEGShoot.data = rand(length(EEGShoot.chanlocs),1000);
[EEG, ~] = pop_tageeg(EEGShoot);

%% Upload datasets to the database (original event types tags)
s = db2mat(DB);                      % get empty structure
s.dataset_name = 'eeglab_data1';      % dataset name is required
s.data = EEG;                        % set data to be stored
[~, uniqueEvents] = mat2db(DB, s);

%% Upload datasets to the database (same event types tags)
s = db2mat(DB);                      % get empty structure
s.dataset_name = 'eeglab_data2';      % dataset name is required
s.data = EEG;                        % set data to be stored
[~, uniqueEvents] = mat2db(DB, s, 'EventTypes', uniqueEvents);

%% Change the tags
[EEG, com] = pop_tageeg(EEG);

%% Upload datasets to the database (different event types tags)
s = db2mat(DB);                      % get empty structure
s.dataset_name = 'eeglab_data3';      % dataset name is required
s.data = EEG;                        % set data to be stored
[~, uniqueEvents] = mat2db(DB, s, 'EventTypes', uniqueEvents);

%% Upload datasets to the database (different event types)
s = db2mat(DB);                      % get empty structure
s.dataset_name = 'eeglab_data4';      % dataset name is required
s.data = EEG;                        % set data to be stored
[UUIDs, uniqueEvents] = mat2db(DB, s);

