function test_suite = testSimple  %#ok<STOUT>
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
function teardown(tStruct) %#ok<DEFNU>
try
    tStruct.DB.commit();
    tStruct.DB.close();
catch ME %#ok<NASGU>
end

function testSimpleModalityUuid(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for storing a simple modality dataset using the' ...
    ' modality uuid:\n']);
fprintf(['It should store a simple modality dataset using the modality' ...
    ' uuid\n']);
DB = tStruct.DB;
load eeglab_data_ch.mat;
s1 = db2mat(DB);
s1.dataset_name = 'simple modality dataset using uuid';
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
UUIDs = mat2db(DB, s1, 'IsUnique', false);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
fprintf('--It should return a dataset that is equal\n');
s2 = db2mat(DB, UUIDs);
assertTrue(isequal(s1.data,s2.data));

function testSimpleModalityName(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for storing a simple modality dataset using the' ...
    ' modality name:\n']);
fprintf(['It should store a simple modality dataset using the modality' ...
    ' name\n']);
DB = tStruct.DB;
load eeglab_data_ch.mat;
s1 = db2mat(DB);
s1.dataset_name = 'simple modality dataset using name';
s1.data = EEG;
s1.dataset_modality_uuid = 'simple';
UUIDs = mat2db(DB, s1, 'IsUnique', false);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
s2 = db2mat(DB, UUIDs);
fprintf('--It should return a dataset that is equal\n');
assertTrue(isequal(s1.data,s2.data));