function test_suite = testEEG  %#ok<STOUT>
initTestSuite;

% Function executed before each test
function tStruct = setup %#ok<DEFNU>

% Structure that holds Mobbed connection object constructor arguments 
tStruct = struct('name', 'testdb', 'url', 'localhost', ...
    'user', 'postgres', 'password', 'admin', 'DB', []);

% Create connection object (create database first if doesn't exist)
try
    DB = Mobbed(tStruct.name, tStruct.url, tStruct.user, tStruct.password);
catch ME %#ok<NASGU>
    Mobbed.createdb(tStruct.name, tStruct.url, tStruct.user, ...
        tStruct.password, 'mobbed.sql');
    DB = Mobbed(tStruct.name, tStruct.url, tStruct.user, tStruct.password);
end
tStruct.DB = DB;

% Get EEG modality uuid
m = getdb(DB, 'modalities', inf);
mNames = {m.modality_name};
pos = strcmp('EEG', mNames);
uuids = {m.modality_uuid};
tStruct.mUUID = uuids{pos};

% Function executed after each test
function teardown(tStruct) %#ok<DEFNU>
try
    tStruct.DB.commit();
    tStruct.DB.close();
catch ME %#ok<NASGU>
end

function testEEG_File(tStruct) %#ok<DEFNU>
% Unit test for EEG modality saved as a file
fprintf('\nUnit test EEG modality saved as a file:\n');

% Create Mobbed connection object
DB = tStruct.DB;

% Load EEG dataset 
load('EEG.mat');

% Store EEG as file
fprintf('It should save an EEG dataset as a file\n');
s1 = getdb(DB, 'datasets', 0);
s1.dataset_name = 'EEG - stored as file';
s1.data = EEG; 
s1.dataset_modality_uuid = tStruct.mUUID;
sUUID = mat2db(DB, s1, false); 

% Retrieve EEG as file
fprintf('It should retrieve an EEG dataset from a file\n');
s2 = db2mat(DB, sUUID);
assertTrue(isequal(s1.data,s2.data));

% Store EEG with no chanlocs as file
fprintf('It should save an EEG dataset with no chanlocs as a file\n');
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'EEG - stored as file';
s1.data = EEG;
s1.data.chanlocs = [];
s1.dataset_modality_uuid = tStruct.mUUID;
sUUID = mat2db(DB, s1, false); 

% Retrieve EEG with no chanlocs as file
fprintf('It should retrieve an EEG dataset from a file with no chanlocs\n');
s2 = db2mat(DB, sUUID);
assertTrue(isequal(s1.data,s2.data));
assertTrue(isempty(s2(1).data.chanlocs));

% Store EEG with no events as file
fprintf('It should save an EEG dataset with no events as a file\n');
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'EEG - stored as file with no chanlocs';
s1.data = EEG;
s1.data.event = [];
s1.dataset_modality_uuid = tStruct.mUUID;
sUUID = mat2db(DB, s1, false); 

% Retrieve EEG with no events as file
fprintf('It should retrieve an EEG dataset from a file with no events\n');
s2 = db2mat(DB, sUUID);
assertTrue(isequal(s1.data,s2.data));
assertTrue(isempty(s2(1).data.event));

% Store EEG with no sampling rate as file
fprintf('It should save an EEG dataset with no sampling rate as a file\n');
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'EEG - stored as file with no sampling rate';
s1.data = EEG;
s1.data.srate = [];
s1.dataset_modality_uuid = tStruct.mUUID;
sUUID = mat2db(DB, s1, false); 

% Retrieve EEG with no sampling rate as file
fprintf('It should retrieve an EEG dataset from a file with no sampling rate\n');
s2 = db2mat(DB, sUUID);
assertTrue(isequal(s1.data,s2.data));

% Store EEG with a negative sampling rate as file
fprintf('It should save an EEG dataset with a negative sampling rate as a file\n');
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'EEG - stored as file with negative sampling rate';
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
sUUID = mat2db(DB, s1, false); 

% Retrieve EEG with a negative sampling rate as file
fprintf('It should retrieve an EEG dataset from a file with a negative sampling rate\n');
s2 = db2mat(DB, sUUID);
assertTrue(isequal(s1.data,s2.data));

% Store EEG with no data as file (should throw exception)
fprintf('It should throw an exception when saving an EEG dataset with no data as a file\n');
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'EEG - stored as file with no data';
s1.data = EEG;
s1.data.data = [];
s1.dataset_modality_uuid = tStruct.mUUID;
assertExceptionThrown(...
    @() error(mat2db(DB, s1, false)), ...
    'EEG_Modality:EEGChannelLocsStructureInvalid');

% Store EEG with invalid modality (should throw exception)
fprintf('It should throw an exception when saving an EEG dataset with an invalid modality as a file\n');
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'EEG - stored as file with invalid modality';
s1.dataset_modality_uuid = randomTestClass.generateRandomUUID;
s1.data = EEG;
assertExceptionThrown(...
    @() error(mat2db(DB, s1, false)), ...
    'VerifyModality:InvalidModality');

fprintf('It should save an EEG dataset with existing events as a file\n');
allEventTypesLength = length(getdb(DB, 'event_types', inf));
mStructure.event_type_entity_uuid = sUUID{1};
allEventTypeMapsLength = length(getdb(DB, 'event_type_maps', inf));
eventTypes = getdb(DB, 'event_type_maps', inf, mStructure);
eventTypes = {eventTypes.event_type_uuid};
eventTypesLength = length(eventTypes);
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'EEG - stored as file with existing events';
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
mat2db(DB, s1, false, 'eventTypes', eventTypes);
allEventTypesLength2 = length(getdb(DB, 'event_types', inf));
allEventTypeMapsLength2 = length(getdb(DB, 'event_type_maps', inf));
assertTrue(isequal(allEventTypesLength, allEventTypesLength2)); 
assertTrue(isequal(allEventTypeMapsLength + eventTypesLength, allEventTypeMapsLength2 )); 


fprintf('It should save an EEG dataset with new events as a file\n');
allEventTypesLength = length(getdb(DB, 'event_types', inf));
allEventTypeMapsLength = length(getdb(DB, 'event_type_maps', inf));
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'EEG - stored as file with new events';
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
sUUID = mat2db(DB, s1, false); 
uniqueEventTypesLength = length(unique({s1.data.event.type}));
allEventTypeMapsLength2 = length(getdb(DB, 'event_type_maps', inf));
allEventTypesLength2 = length(getdb(DB, 'event_types', inf));
assertTrue(isequal(allEventTypesLength + uniqueEventTypesLength, allEventTypesLength2)); 
assertTrue(isequal(allEventTypeMapsLength + uniqueEventTypesLength, allEventTypeMapsLength2 )); 

fprintf('It should save an EEG dataset with existing events with opposite case in as a file \n');
allEventTypesLength = length(getdb(DB, 'event_types', inf));
mStructure.event_type_entity_uuid = sUUID{1};
allEventTypeMapsLength = length(getdb(DB, 'event_type_maps', inf));
eventTypes = getdb(DB, 'event_type_maps', inf, mStructure);
eventTypes = {eventTypes.event_type_uuid};
eventTypesLength = length(eventTypes);
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'EEG - stored in file with existing events with opposite case';
s1.data = EEG;
upperCaseEvents = arrayfun(@(x) upper(x.type), s1.data.event, 'UniformOutput', false); 
[s1.data.event.type] = upperCaseEvents{:};
s1.dataset_modality_uuid = tStruct.mUUID;
mat2db(DB, s1, false, 'eventTypes', eventTypes);
allEventTypeMapsLength2 = length(getdb(DB, 'event_type_maps', inf));
allEventTypesLength2 = length(getdb(DB, 'event_types', inf));
assertTrue(isequal(allEventTypesLength, allEventTypesLength2));
assertTrue(isequal(allEventTypeMapsLength + eventTypesLength, allEventTypeMapsLength2 )); 

fprintf('It should save an EEG dataset that returns unique events with new events as a file\n');
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'EEG - return unique events';
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
[sUUID, uniqueEvents] = mat2db(DB, s1, false);
uniqueEvents2 = unique({s1.data.event.type});
assertTrue(iscellstr(sUUID));
assertTrue(isequal(length(uniqueEvents), length(uniqueEvents2)));

fprintf('It should save an EEG dataset that returns unique events with existing events as a file\n');
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'EEG - return unique events';
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
[sUUID, uniqueEvents] = mat2db(DB, s1, false, 'eventTypes', uniqueEvents);
uniqueEvents2 = unique({s1.data.event.type});
assertTrue(iscellstr(sUUID));
assertTrue(isequal(length(uniqueEvents), length(uniqueEvents2)));

fprintf('It should save a strucuture array of EEG datasets that returns unique events with the same events as a file\n');
s1(1).dataset_name = 'EEG - dataset 1';
s1(1).data = EEG;
s1(2).dataset_name = 'EEG - dataset 2';
s1(2).data = EEG;
[sUUID, uniqueEvents] = mat2db(DB, s1, false);
assertTrue(iscellstr(sUUID));
assertTrue(isequal(length(uniqueEvents), length(uniqueEvents2)));

fprintf('It should save a strucuture array of EEG datasets that returns unique events with different events as a file\n');
s1(2).data.event(1).type = 'new unique event type';
[sUUID, uniqueEvents] = mat2db(DB, s1, false);
uniqueEvents2 = union(unique({s1(1).data.event.type}), unique({s1(2).data.event.type}));
assertTrue(iscellstr(sUUID));
assertTrue(isequal(length(uniqueEvents), length(uniqueEvents2)));