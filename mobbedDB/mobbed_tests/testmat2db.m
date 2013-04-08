function test_suite = testmat2db  %#ok<STOUT>
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

% Function executed after each test
function teardown(tStruct) %#ok<DEFNU>
try
    tStruct.DB.commit();
    tStruct.DB.close();
catch ME %#ok<NASGU>
end

function testMat2dbNoData(tStruct) %#ok<DEFNU>
fprintf('It should save a dataset with no data\n');
DB = tStruct.DB;
s1 = db2mat(DB); 
s1.dataset_name = 'mat2db - no data';
s1.data = [];
UUIDs = mat2db(DB, s1, false); 
fprintf('It should retrieve a dataset with no data\n');
s2 = db2mat(DB, UUIDs);
assertTrue(isequal(s1.data,s2.data));
assertTrue(isempty(s2.data));

function testMat2dbTags(tStruct) %#ok<DEFNU>
fprintf('It should save a dataset with tags\n');
DB = tStruct.DB;
s1 = db2mat(DB); 
s1.dataset_name = 'mat2db - tags';
s1.data = [];
mat2db(DB, s1, false, 'Tags', {'tag1', 'tag2'}); 
s2 = getdb(DB, 'datasets', 1, 'Tags', {'tag1', 'tag2'});
s3 = db2mat(DB, {s2.dataset_uuid});
assertTrue(isequal(s1.data,s3.data));

