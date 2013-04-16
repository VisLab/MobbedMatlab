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

function testmat2dbNoData(tStruct) %#ok<DEFNU>
fprintf('\nIt should store a dataset with no data\n');
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = 'mat2db - no data';
UUIDs = mat2db(DB, s1, false);
s2 = db2mat(DB, UUIDs);
assertTrue(isempty(s2.data));
assertTrue(isequal(s1.data,s2.data));

function testmat2dbTags(tStruct) %#ok<DEFNU>
fprintf('\nIt should store a dataset with tags\n');
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = 'mat2db - tags';
mat2db(DB, s1, false, 'Tags', {'tag1', 'tag2'});
s2 = getdb(DB, 'datasets', 1, 'Tags', {'tag1', 'tag2'});
assertTrue(~isempty(s2));

function testmat2dbNoName(tStruct) %#ok<DEFNU>
fprintf('\nIt should throw an exception when a dataset has no name\n');
DB = tStruct.DB;
s1 = db2mat(DB);
assertExceptionThrown(...
    @() error(mat2db(DB, s1, false)), 'mat2db:noDatasetName');

