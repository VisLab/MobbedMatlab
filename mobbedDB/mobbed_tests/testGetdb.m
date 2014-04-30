function test_suite = testGetdb %#ok<STOUT>
initTestSuite;

% Function executed before each tests
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

function testExactMatchTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with tags that are a exact match\n');
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = 'dataset with exact match tag';
mat2db(DB, s1, 'IsUnique', false, 'Tags', 'ExactMatchTag');
s2 = getdb(DB, 'datasets', 1, 'Tags', {{'ExactMatchTag'}});
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s2));
assertEqual(1, length(s2));