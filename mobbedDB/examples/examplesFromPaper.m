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

%% 4.3 Upload datasets to the database (no optional parameters)
load eeglab_data_ch.mat;             % load saved EEG structure
s = db2mat(DB);                      % get empty structure
s.dataset_name = 'eeglab_data';      % dataset name is required
s.data = EEG;                        % set data to be stored
sUUID = mat2db(DB, s);               %#ok<NASGU> % store in database DB

%% 4.3 Upload datasets to the database (optional parameters)
sUUID = mat2db(DB, s, true, 'Tags', {'EyeTrack', 'VisualTarget', 'AudioLeft'});

%% 4.4 Search for datasets from the database (get all rows)
s = getdb(DB, 'datasets', inf); %#ok<NASGU> all rows in datasets table

%% 4.4 Searching for datasets from the database (search qualifications)
s = getdb(DB, 'datasets', 0);
s.dataset_name = 'eeg*';
sNew = getdb(DB, 'datasets', 10, s, 'RegExp', 'on', ...
    'Tags', {{'EyeTrack'}, {'VisualTarget', 'Audio*'}}); %#ok<NASGU>

%% 4.4 Searching for datasets from the database (search qualifications)
sNew = getdb(DB, 'datasets', 10, s, 'RegExp', 'on', ...
    'Tags', {'EyeTrack', 'VisualTarget', 'Audio*'});

%% 4.4 Retrieving datasets from the database
UUIDs = {sNew.dataset_uuid};
datasets = db2mat(DB, UUIDs);
EEG = datasets(1).data;

%% 4.5 Events with unique events - store 10 copies of sample EEG (as data1....)
uniqueEvents = {};
s = db2mat(DB);
UUIDs = cell(10, 1);
for k = 1:10
    s.dataset_name = ['eeg_data_ch' num2str(k) '.mat'];
    load(s.dataset_name);
    s.data = EEG;
    [UUIDs(k), uniqueEvents] = ...
        mat2db(DB, s, true, 'EventTypes', uniqueEvents);
end

%% 4.6 Storing the EEG data frames individually in the database
sdef = db2data(DB);    % get an empty data definition template
sdef.datadef_format = 'NUMERIC_STREAM';
sdef.datadef_sampling_rate = EEG.srate;
sdef.datadef_description = [EEG.setname ' individual frames'];
sdef.data = EEG.data;
sdefUUID = data2db(DB, sdef);       % store frames in database

%% 4.6 Associating exploded frames with multiple datasets.
smap = getdb(DB, 'datamaps', 0);
smap.datamap_def_uuid = sdefUUID{1};
smap.datamap_structure_path = '/EEG/dataEx'; % load destination
for k = 1:10
    smap.datamap_entity_uuid = UUIDs{k};
    smap.datamap_entity_class = 'datasets';
    putdb(DB, 'datamaps', smap);
end
commit(DB);

%% 4.6 Retrieving an exploded dataset
ddef = db2data(DB, sdefUUID);    %#ok<NASGU> % ddef.data has the actual data

%% 4.6 Get the extra data associated with a particular dataset dUUID
smap = getdb(DB, 'datamaps', 0);
smap.datamap_entity_uuid = UUIDs{1}; % pick first dataset to try
dmaps = getdb(DB, 'datamaps', inf, smap);  % retrieve all data
ddef = db2data(DB, dmaps);           % get data in structured form

%% 4.6 Caching, reuse, and standardization
EEG = pop_eegfilt(EEG, 1.0, 0, [], 0);
s = db2mat(DB);
s.dataset_name = 'eeglab_data_filtered.set';
s.data = EEG;
s.dataset_parent_uuid = sUUID{1};
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