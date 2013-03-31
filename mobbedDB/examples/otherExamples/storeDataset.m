% This script will store data in the database using different arguments 

%% Create Connection
DB = Mobbed('mobbed', 'localhost', 'postgres', 'admin');

%% Store data using default arguments 
EEG = pop_loadset('filename', 'eeglab_data.set');
s = getdb(DB, 'datasets', 0);
s.dataset_name = 'Data1.mat';
s.data = EEG;
sUUID = mat2db(DB, s); 

%% Store data in tables and as a file
EEG = pop_loadset('filename', 'eeglab_data.set');
s = getdb(DB, 'datasets', 0);
s.dataset_name = 'Data2.mat';
s.data = EEG;
sUUID1 = mat2db(DB, s, false); 

%% Store data as a duplicate 
EEG = pop_loadset('filename', 'eeglab_data.set');
s = getdb(DB, 'datasets', 0);
s.dataset_name = 'Data2.mat';
s.data = EEG;
sUUID2 = mat2db(DB, s, true, false); 

%% Store data with tags 
EEG = pop_loadset('filename', 'eeglab_data.set');
s = getdb(DB, 'datasets', 0);
s.dataset_name = 'Data3.mat';
s.data = EEG;
sUUID3 = mat2db(DB, s, true, false, 'Tags', {'EyeTrack', 'Oddball', 'AudioLeft'}); 

%% Store data with existing event types  
datasets = getdb(DB, 'datasets', inf);
eventMap = getdb(DB, 'event_type_map', 0);
eventMap.event_type_entity_uuid = datasets(1).dataset_uuid;
eventyTypeMaps = getdb(DB, 'event_type_map', inf, eventMap);
eventTypes = {eventyTypeMaps.event_type_uuid};
EEG = pop_loadset('filename', 'eeglab_data.set');
s = getdb(DB, 'datasets', 0);
s.dataset_name = 'Data4.mat';
s.data = EEG;
sUUID4 = mat2db(DB, s, true, false, 'EventTypes', eventTypes);