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
% Unit test for EEG modality saved as a file
fprintf('\nIt should store a simple dataset using the modality uuid\n');
DB = tStruct.DB;
load eeglab_data_ch.mat;
s1 = getdb(DB, 'datasets', 0);
s1.dataset_name = 'simple - modality uuid';
s1.data = EEG; 
s1.dataset_modality_uuid = tStruct.mUUID;
UUIDs = mat2db(DB, s1, false); 
s2 = db2mat(DB, UUIDs);
assertTrue(isequal(s1.data,s2.data));

function testSimpleModalityName(tStruct) %#ok<DEFNU>
% Unit test for EEG modality saved as a file
fprintf('\nIt should store a simple dataset using the modality name\n');
DB = tStruct.DB;
load eeglab_data_ch.mat;
s1 = getdb(DB, 'datasets', 0);
s1.dataset_name = 'simple - modality name';
s1.data = EEG; 
s1.dataset_modality_uuid = 'simple';
UUIDs = mat2db(DB, s1, false); 
s2 = db2mat(DB, UUIDs);
assertTrue(isequal(s1.data,s2.data));