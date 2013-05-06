function test_suite = testmat2db   %#ok<STOUT>
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
function teardown(tStruct) %#ok<DEFNU>
try
    tStruct.DB.commit();
    tStruct.DB.close();
catch ME %#ok<NASGU>
end

function testmat2DuplicateDataset(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for mat2db with duplicate dataset\n');
fprintf('It should store a duplicate dataset\n');
DB = tStruct.DB;
load eeglab_data_ch.mat;
s1 = db2mat(DB);
s1.dataset_name = 'mat2db duplicate dataset';
s1.data = EEG;
mat2db(DB, s1);
s2 = db2mat(DB);
s2.dataset_name = 'mat2db duplicate dataset';
s2.data = EEG;
UUIDs = mat2db(DB, s2, 'IsUnique', false);
s3 = db2mat(DB,UUIDs);
fprintf('--It return a dataset with a version number greater than 1\n');
assertTrue(s3.dataset_version > 1);


function testmat2UniqueDatasetException(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for mat2db with unique dataset exception\n');
fprintf(['It should throw an exception when storing a unique dataset' ...
    ' whose namespace and name combination already exist\n']);
DB = tStruct.DB;
load eeglab_data_ch.mat;
s1 = db2mat(DB);
s1.dataset_name = 'mat2db unique dataset';
s1.data = EEG;
mat2db(DB, s1);
s2 = db2mat(DB);
s2.dataset_name = 'mat2db unique dataset';
s2.data = EEG;
assertExceptionThrown(@() error(mat2db(DB, s2)), ...
    'MATLAB:Java:GenericException');

function testmat2dbTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for mat2db with tags:\n');
fprintf('It should store a dataset with tags\n');
DB = tStruct.DB;
load eeglab_data_ch.mat;
s1 = db2mat(DB);
s1.dataset_name = 'mat2db with tags';
s1.data = EEG;
mat2db(DB, s1, 'IsUnique', false, 'Tags', {'tag1', 'tag2'});
fprintf(['--It should retrieve a dataset by the tags that were' ...
    ' associated with it\n']);
s2 = getdb(DB, 'datasets', 1, 'Tags', {'tag1', 'tag2'});
assertTrue(~isempty(s2));
