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
function teardown(tStruct) %#ok<DEFNU>
try
    tStruct.DB.commit();
    tStruct.DB.close();
catch ME %#ok<NASGU>
end

function testExactMatchTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with tags that are a exact match\n');
fprintf('It should retrieve a dataset by a tag that is a exact match\n');
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = 'dataset with exact match tag';
mat2db(DB, s1, 'IsUnique', false, 'Tags', 'ExactMatchTag');
s2 = getdb(DB, 'datasets', 1, 'Tags', {{'ExactMatchTag'}});
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s2));
assertEqual(1, length(s2));

function testRegExpTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with tags that are regular expressions\n');
fprintf(['It should retrieve a dataset by a tag that is a regular' ...
' expression\n']);
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = 'dataset with reg exp tag';
mat2db(DB, s1, 'IsUnique', false, 'Tags', 'RegExpTag');
s2 = getdb(DB, 'datasets', 1, 'Tags', {{'RegExpT*'}}, 'RegExp', 'on');
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s2));
assertEqual(1, length(s2));

function testORConditionTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with tags using the OR condition\n');
fprintf('It should retrieve a dataset by tags using the OR condition\n');
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = 'dataset with OR condition tags';
mat2db(DB, s1, 'IsUnique', false, 'Tags', {'ORTAG1','ORTAG2'});
s2 = getdb(DB, 'datasets', 1, 'Tags', {{'ORTAG1','ORTAG2'}});
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s2));
assertEqual(1, length(s2));

function testANDConditionTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with tags using the AND condition\n');
fprintf('It should retrieve a dataset by tags using the AND condition\n');
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = 'dataset with AND condition tags';
mat2db(DB, s1, 'IsUnique', false, 'Tags', {'ANDTAG1','ANDTAG2'});
s2 = getdb(DB, 'datasets', 1, 'Tags', {'ANDTAG1', 'ANDTAG2'});
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s2));
assertEqual(1, length(s2));

function testORANDConditionTags(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for getdb with tags using the OR and AND' ...
    ' conditions\n']);
fprintf(['It should retrieve a dataset by tags using the OR and AND' ...
    ' condition\n']);
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = 'dataset with OR and AND condition tags';
mat2db(DB, s1, 'IsUnique', false, 'Tags', {'ORANDTAG1', 'ORANDTAG2', ...
    'ORANDTAG3'});
s2 = getdb(DB, 'datasets', 1, 'Tags', {{'ORANDTAG1'},{'ORANDTAG2', ...
    'ORANDTAG3'}});
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s2));
assertEqual(1, length(s2));
