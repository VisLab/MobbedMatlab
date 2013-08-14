function test_suite = testEEG  %#ok<STOUT>
initTestSuite;

% Function executed before each test
function tStruct = setup %#ok<DEFNU>

% Structure that holds Mobbed connection object constructor arguments
tStruct = struct('name', 'testdb', 'url', 'localhost', ...
    'user', 'postgres', 'password', 'admin', 'DB', []);

% Create connection object (create database first if doesn't exist)
try
    DB = Mobbed(tStruct.name, tStruct.url, tStruct.user, ...
        tStruct.password, false);
catch ME %#ok<NASGU>
    Mobbed.createdb(tStruct.name, tStruct.url, tStruct.user, ...
        tStruct.password, 'mobbed.sql', false);
    DB = Mobbed(tStruct.name, tStruct.url, tStruct.user, ...
        tStruct.password, false);
end
tStruct.DB = DB;

% Get EEG modality uuid
m = getdb(DB, 'modalities', inf);
mNames = {m.modality_name};
pos = strcmp('EEG', mNames);
uuids = {m.modality_uuid};
tStruct.mUUID = uuids{pos};

% Function executed after each test
function teardown(~) %#ok<DEFNU>
try
    Mobbed.closeall();
catch ME %#ok<NASGU>
end

function testChanlocsAndEvents(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for EEG modality dataset with chanlocs and' ...
    ' events:\n']);
fprintf(['It should store a EEG modality dataset with chanlocs and' ...
    ' events\n']);
DB = tStruct.DB;
load eeg_data_ch1.mat;
s1 = db2mat(DB);
s1.dataset_name = 'eeg chanlocs and events';
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
UUIDs = mat2db(DB, s1, 'IsUnique', false);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
s2 = db2mat(DB, UUIDs);
fprintf('--It should return a dataset that is equal\n');
assertTrue(isequal(s1.data,s2.data));

function testNoChanlocs(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for EEG modality dataset with no chanlocs:\n');
fprintf('It should store a EEG modality dataset with no chanlocs\n');
DB = tStruct.DB;
load eeg_data_ch1.mat;
s1 = db2mat(DB);
s1.dataset_name = 'eeg no chanlocs';
s1.data = EEG;
s1.data.chanlocs = [];
s1.dataset_modality_uuid = tStruct.mUUID;
UUIDs = mat2db(DB, s1, 'IsUnique', false);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
s2 = db2mat(DB, UUIDs);
fprintf('--It should return a dataset that is equal\n');
assertTrue(isequal(s1.data,s2.data));
fprintf('--It should return a dataset that has no chanlocs\n');
assertTrue(isempty(s2.data.chanlocs));

function testNoEvents(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for EEG modality dataset with no events:\n');
fprintf('It should store a EEG modality dataset with no events\n');
DB = tStruct.DB;
load eeg_data_ch1.mat;
s1 = db2mat(DB);
s1.dataset_name = 'eeg no events';
s1.data = EEG;
s1.data.event = [];
s1.dataset_modality_uuid = tStruct.mUUID;
UUIDs = mat2db(DB, s1, 'IsUnique', false);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
s2 = db2mat(DB, UUIDs);
fprintf('--It should return a dataset that is equal\n');
assertTrue(isequal(s1.data,s2.data));
fprintf('--It should return a dataset that has no events\n');
assertTrue(isempty(s2.data.event));

function testModalityName(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for EEG modality dataset using the modality name:\n');
fprintf(['It should store a EEG modality dataset using the modality' ...
    ' name\n']);
DB = tStruct.DB;
load eeg_data_ch1.mat;
s1 = db2mat(DB);
s1.dataset_name = 'eeg modality name';
s1.data = EEG;
s1.dataset_modality_uuid = 'EEG';
UUIDs = mat2db(DB, s1, 'IsUnique', false);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
s2 = db2mat(DB, UUIDs);
fprintf('--It should return a dataset that is equal\n');
assertTrue(isequal(s1.data,s2.data));

function testDefaultModality(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for EEG modality dataset using the default' ...
    ' modality which is EEG:\n']);
fprintf(['It should store a EEG modality dataset using the default' ...
    ' EEG modality\n']);
DB = tStruct.DB;
load eeg_data_ch1.mat;
s1 = db2mat(DB);
s1.dataset_name = 'eeg default modality';
s1.data = EEG;
UUIDs = mat2db(DB, s1, 'IsUnique', false);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
s2 = db2mat(DB, UUIDs);
fprintf('--It should return a dataset that is equal\n');
assertTrue(isequal(s1.data,s2.data));

function testReuseEventTypes(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for EEG modality dataset that reuses events:\n');
fprintf(['It should store a EEG modality dataset that reuses event' ...
    ' types\n']);
DB = tStruct.DB;
load eeg_data_ch1.mat;
s1 = db2mat(DB);
s1.dataset_name = 'EEG - original event types';
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
[~, uniqueEvents1] = mat2db(DB, s1, 'IsUnique', false);
fprintf(['--It should return a cell array containing the string uuids' ...
    ' of the unique event types \n']);
assertTrue(iscellstr(uniqueEvents1));
s2 = db2mat(DB);
s2.dataset_name = 'EEG - reuses event types';
s2.data = EEG;
s2.dataset_modality_uuid = tStruct.mUUID;
[~, uniqueEvents2] = mat2db(DB, s2, 'IsUnique', false, 'EventTypes', ...
    uniqueEvents1);
fprintf(['--It should return a cell array containing the same number' ...
    ' of string uuids of the event types\n']);
assertTrue(isequal(length(uniqueEvents1), length(uniqueEvents2)));

function testUniqueEventTypes(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for EEG modality dataset that reuses event types' ...
    ' but also has unique event types:\n']);
fprintf(['It should store a EEG modality dataset that reuses event' ...
    ' types but also has unique event types\n']);
DB = tStruct.DB;
load eeg_data_ch1.mat;
s1 = db2mat(DB);
s1.dataset_name = 'mat2db original event types';
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
[~, uniqueEvents1] = mat2db(DB, s1, 'IsUnique', false);
fprintf(['--It should return a cell array containing the string uuids' ...
    ' of the unique event types\n']);
assertTrue(iscellstr(uniqueEvents1));
s2 = db2mat(DB);
s2.dataset_name = 'EEG - unique event types';
s2.data = EEG;
s2.data.event(1).type = 'unique event type 1';
s2.data.event(2).type = 'unique event type 2';
s2.dataset_modality_uuid = tStruct.mUUID;
[~, uniqueEvents2] = mat2db(DB, s2, 'IsUnique', false, 'EventTypes', ...
    uniqueEvents1);
fprintf(['--It should return a cell array containing two more string' ...
    ' uuids of the event types\n']);
assertTrue(isequal(length(uniqueEvents1) + 2, length(uniqueEvents2)));