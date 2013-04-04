function test_suite = testsimple  %#ok<STOUT>
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

function testSimple(tStruct) %#ok<DEFNU>
% Unit test for EEG modality saved as a file
fprintf('\nUnit test EEG modality saved as a file:\n');

% Create Mobbed connection object
DB = tStruct.DB;

% Load EEG dataset 
load('EEG.mat');

% Store EEG as file
fprintf('It should save an EEG dataset as a file\n');
s1 = getdb(DB, 'datasets', 0);
s1.dataset_name = 'Simple';
s1.data = EEG; 
s1.dataset_modality_uuid = tStruct.mUUID;
sUUID = mat2db(DB, s1, false); 
assertTrue(iscell(sUUID));
assertTrue(~isempty(sUUID));