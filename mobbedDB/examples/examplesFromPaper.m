%% 4.1 Create a database
Mobbed.createdb('mobbed', 'localhost', 'postgres', 'admin', 'mobbed.sql');

%% 4.1 Delete a database
Mobbed.deletedb('mobbed', 'localhost', 'postgres', 'admin');

%% 4.1 Recreate a database
Mobbed.createdb('mobbed', 'localhost', 'postgres', 'admin', 'mobbed.sql');

%% 4.2 Accessing the database in MATLAB
DB = Mobbed('mobbed', 'localhost', 'postgres', 'admin');

%% 4.2 Close connection
close(DB);

%% 4.2 Reopen the connection
DB = Mobbed('mobbed', 'localhost', 'postgres', 'admin');

%% Get empty structure
s = db2mat(DB);

%% 4.3 Upload datasets to the database (no optional parameters)
load eeglab_data_ch.mat;
s = getdb(DB, 'datasets', 0);
s.dataset_name = 'eeglab_data';
s.data = EEG;
sUUID = mat2db(DB, s);

%% 4.3 Upload datasets to the database (optional parameters)
load eeglab_data_ch.mat;
s = getdb(DB, 'datasets', 0);
s.dataset_name = 'eeglab_data1';
s.data = EEG;
sUUID1 = mat2db(DB, s, true, 'Tags', {'EyeTrack', 'Oddball', 'AudioLeft'});

% Create another version with slightly different tags for later retrieval
s.dataset_name = 'eeglab_data2';
s.data = EEG;
sUUID2 = mat2db(DB, s, false, 'Tags', {'EyeTrack', 'Oddball'});

s.dataset_name = 'eeglab_data3';
s.data = EEG;
sUUID3 = mat2db(DB, s, false, 'Tags', {'EyeTrack', 'VisualTarget', 'AudioLeft'});
%% 4.4 Search for datasets from the database (get all rows)
s = getdb(DB, 'datasets', inf); %#ok<NASGU>


%% 4.4 Searching for datasets from the database (search qualifications)
s = getdb(DB, 'datasets', 0);
s.dataset_name = 'eeg*';
sNew1 = getdb(DB, 'datasets', 10, s, 'RegExp', 'on', ...
    'Tags', {{'EyeTrack'}, {'VisualTarget', 'Audio*'}});

sNew2 = getdb(DB, 'datasets', 10, s, 'RegExp', 'on', ...
    'Tags', {'EyeTrack', 'VisualTarget', 'Audio*'});

%% 4.4 Retrieving datasets from the database
UUIDs = {sNew1.dataset_uuid};
datasets = db2mat(DB, UUIDs);
EEG1 = datasets(1).data;

%% 4.4 Retrieve multiple datasets from the database
UUIDs = {sUUID1{1}, sUUID2{1}, sUUID3{1}};
mData = db2mat(DB, UUIDs);

%% 4.5 Events with unique events - store 10 copies of sample EEG (as data1....)
load eeglab_data_ch.mat;
uniqueEvents = {};
s = getdb(DB, 'datasets', 0);
eventMap = getdb(DB, 'event_type_maps', 0);
sNewF = cell(10, 1);
for k = 1:10
    s.dataset_name = ['data' num2str(k) '.mat'];
    s.data = EEG;
    [sNewF(k), uniqueEvents] = mat2db(DB, s, false, 'EventTypes', uniqueEvents);
end

%% 4.5 Retrieve datasets with specified unique events
sETM = getdb(DB, 'event_type_maps', 0);
sETM.event_type_uuid = uniqueEvents;
s = getdb(DB, 'event_type_maps', inf, sETM);

%% 4.6 Storing the EEG data frames individually in the database
sdef = getdb(DB, 'data_defs', 0);          % set the data definition template
sdef.data_def_format = 'NUMERIC_STREAM';
sdef.data_def_sampling_rate = EEG.srate;
sdef.data = EEG.data;
sdef.data_def_description = [EEG.setname ' ' EEG.filename ' individual frames'];
sdefUUID = data2db(DB, sdef);            % store the frames in the database

%% 4.6 Associating exploded frames with multiple datasets.
smap = getdb(DB, 'data_maps', 0);
smap.data_map_def_uuid = sdefUUID{1};
smap.data_map_structure_path = '/EEG/dataEx'; % where to put on retrieval
for k = 1:10
    smap.data_map_entity_uuid = sNewF{k};
    putdb(DB, 'data_maps', smap);
end
commit(DB);

%% 4.6 Retrieving an exploded dataset
ddef = db2data(DB, sdefUUID);    % ddef.data has the actual data

%% 4.6 Get the extra data associated with a particular dataset dUUID
dUUID = sNewF{1};     % pick the first dataset of the 10 above to try
smap = getdb(DB, 'data_maps', 0);
smap.data_map_entity_uuid = dUUID;
dmaps = getdb(DB, 'data_maps', inf, smap);  % retrieve all data
for j = 1:length(dmaps)
    ddef = db2data(DB, dmaps(j).data_map_def_uuid); % get the data
    pathName = strrep(dmaps(j).data_map_structure_path, '/', '.');
    eval([pathName(2:end) '= ddef.data']); % put in right structure
end

%% 4.6 Caching, reuse, and standardization
load eeglab_data_ch.mat;
EEG = pop_eegfilt(EEG, 1.0, 0, [], 0);
s = getdb(DB, 'datasets', 0);
s.dataset_name = 'eeglab_data_filtered.set';
s.data = EEG;
s.dataset_parent_uuid = sUUID;
sNewF = mat2db(DB, s, true);

tString = ['pop_eegfilt((' sUUID{1} '),1.0,0,[],0)'];

t = getdb(DB, 'transforms', 0);
t.transform_uuid = sNewF{1};
t.transform_string = tString;
t.transform_description = 'Used EEGLAB FIR filter [1.0, 0]';
putdb(DB, 'transforms', t);
commit(DB);

t = getdb(DB, 'transforms', 0);
t.transform_string = tString;
cached = getdb(DB, 'transforms', inf, t);
filtEEG = db2mat(DB, cached.transform_uuid);