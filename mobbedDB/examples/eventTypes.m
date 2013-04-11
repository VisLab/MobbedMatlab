%% 4.1 Delete a database
Mobbed.deletedb('mobbed', 'localhost', 'postgres', 'admin');

%% 4.1 Recreate a database
Mobbed.createdb('mobbed', 'localhost', 'postgres', 'admin', 'mobbed.sql');

%% 4.2 Accessing the database in MATLAB
DB = Mobbed('mobbed', 'localhost', 'postgres', 'admin');

%% Reuse events 
load eeglab_data_ch.mat;             % load saved EEG structure
s = db2mat(DB);                      % get empty structure
s.dataset_name = 'eeglab_data';      % dataset name is required
s.data = EEG;                        % set data to be stored
[UUIDs, uniqueEvents] = mat2db(DB, s, false, 'eventTypes', {});

%% 4.2 Close connection
close(DB);