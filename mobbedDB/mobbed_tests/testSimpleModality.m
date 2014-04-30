function test_suite = testSimpleModality  %#ok<STOUT>
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

% Retrieve SIMPLE modality UUID
m = getdb(DB, 'modalities', inf);
mNames = {m.modality_name};
pos = strcmp('SIMPLE', mNames);
uuids = {m.modality_uuid};
tStruct.mUUID = uuids{pos};

% Function executed after each test
function teardown(~) %#ok<DEFNU>
try
    Mobbed.closeall();
catch ME %#ok<NASGU>
end

function testModalityUuid(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for storing a simple modality dataset by' ...
    ' specifying the modality uuid\n']);
DB = tStruct.DB;
load eeg_data_ch1.mat;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
UUIDs = mat2db(DB, s1, 'IsUnique', false);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
s2 = db2mat(DB, UUIDs);
fprintf(['--It should have a modality uuid stored in the database' ...
    ' that is equal to the SIMPLE modality uuid in the modalities' ...
    ' table\n']);
assertEqual(s2.dataset_modality_uuid,tStruct.mUUID);

function testModalityName(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for storing a simple modality dataset by' ...
    ' specifying the modality name instead of its modality uuid\n']);
DB = tStruct.DB;
load eeg_data_ch1.mat;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
s1.data = EEG;
s1.dataset_modality_uuid = 'SIMPLE';
UUIDs = mat2db(DB, s1, 'IsUnique', false);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
s2 = db2mat(DB, UUIDs);
fprintf(['--It should have the modality uuid stored in the database' ...
    ' instead of the modality name\n']);
assertEqual(s2.dataset_modality_uuid,tStruct.mUUID);
