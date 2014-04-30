function test_suite = testMat2db   %#ok<STOUT>
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

% Function executed after each test
function teardown(~) %#ok<DEFNU>
try
    Mobbed.closeall();
catch ME %#ok<NASGU>
end

function testMultipleDatasets(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for mat2db with multiple datasets\n');
DB = tStruct.DB;
load eeg_data_ch1.mat;
s(1) = db2mat(DB);
s(1).dataset_name = randomClass.generateUUID();
s(1).data = EEG;
s(2) = db2mat(DB);
s(2).dataset_name = randomClass.generateUUID();
s(2).data = EEG;
UUIDs = mat2db(DB, s, 'IsUnique', false);
fprintf('--It should return a cell array containing two string uuids\n');
assertTrue(isequal(length(UUIDs), 2));
assertFalse(isequal(UUIDs{1}, UUIDs{2}));

function testDuplicateDataset(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for mat2db with duplicate dataset\n');
DB = tStruct.DB;
load eeg_data_ch1.mat;
duplicate_name = randomClass.generateUUID();
s1 = db2mat(DB);
s1.dataset_name = duplicate_name;
s1.data = EEG;
UUIDs = mat2db(DB, s1, 'IsUnique', false);
s1 = db2mat(DB, UUIDs);
version1 = str2double(s1.dataset_version);
s2 = db2mat(DB);
s2.dataset_name = duplicate_name;
s2.data = EEG;
UUIDs = mat2db(DB, s2, 'IsUnique', false);
s2 = db2mat(DB, UUIDs);
version2 = str2double(s2.dataset_version);
fprintf(['--It should return a dataset version that has been'  ...
    ' incremented by 1\n']);
assertEqual(version1 + 1, version2);


function testUniqueDatasetException(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for mat2db with unique dataset exception\n');
DB = tStruct.DB;
load eeg_data_ch1.mat;
duplicate_name = randomClass.generateUUID();
s1 = db2mat(DB);
s1.dataset_name = duplicate_name;
s1.data = EEG;
mat2db(DB, s1, 'IsUnique', false);
s2 = db2mat(DB);
s2.dataset_name = duplicate_name;
s2.data = EEG;
fprintf('--It should throw an exception and not store the dataset\n');
assertExceptionThrown(@() error(mat2db(DB, s2)), ...
    'MATLAB:Java:GenericException');

function testTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for mat2db with tags\n');
DB = tStruct.DB;
load eeg_data_ch1.mat;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
s1.data = EEG;
mat2db(DB, s1, 'IsUnique', false, 'Tags', {'tag1', 'tag2'});
fprintf(['--It should retrieve a dataset by the tags that were' ...
    ' associated with it\n']);
s2 = getdb(DB, 'datasets', 1, 'Tags', {'tag1', 'tag2'});
assertTrue(~isempty(s2));

function testRollback(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for mat2db with rollback\n');
DB = tStruct.DB;
load eeg_data_ch1.mat;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
s1.data = EEG;
numchans = length(s1.data.chanlocs);
s1.data.chanlocs(numchans+1) = s1.data.chanlocs(1);
assertExceptionThrown(@() error(mat2db(DB, s1, 'IsUnique', false)), ...
    'EEG_Modality:EEGChannelLocsStructureInvalid');
fprintf('--There should be no dataset stored in the database\n');
s2.dataset_name = 'mat2db with rollback';
s3 = getdb(DB, 'datasets', 1, s2);
assertTrue(isempty(s3));