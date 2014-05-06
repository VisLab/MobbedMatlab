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
s1.dataset_name = randomClass.generateUUID();
UUID = mat2db(DB, s1, 'IsUnique', false, 'Tags', 'a/b/c');
s2 = getdb(DB, 'datasets', 0);
s2.dataset_uuid = UUID{1};
s3 = getdb(DB, 'datasets', inf, s2, 'Tags', {{'a/b/c'}});
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s3));
assertEqual(1, length(s3));

function testExactMatchORTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with tags that are a exact match\n');
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
UUID = mat2db(DB, s1, 'IsUnique', false, 'Tags', {'a/b/c','d/e/f/g'});
s2 = getdb(DB, 'datasets', 0);
s2.dataset_uuid = UUID{1};
s3 = getdb(DB, 'datasets', inf, s2, 'Tags', {{'a/b/c','d/e/f/g'}});
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s3));
assertEqual(1, length(s3));

function testExactMatchANDTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with tags that are a exact match\n');
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
UUID = mat2db(DB, s1, 'IsUnique', false, 'Tags', {'a/b/c','d/e/f/g'});
s2 = getdb(DB, 'datasets', 0);
s2.dataset_uuid = UUID{1};
s3 = getdb(DB, 'datasets', inf, s2, 'Tags', {{'a/b/c'},{'d/e/f/g'}});
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s3));
assertEqual(1, length(s3));

function testPrefixMatchTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with tags that are a prefix match\n');
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
UUID = mat2db(DB, s1, 'IsUnique', false, 'Tags', 'a/b/c');
s2 = getdb(DB, 'datasets', 0);
s2.dataset_uuid = UUID{1};
s3 = getdb(DB, 'datasets', inf, s2, 'TagMatch', 'prefix','Tags', ...
    {{'a/b/'}});
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s3));
assertEqual(1, length(s3));

function testPrefixMatchORTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with tags that are a prefix match\n');
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
UUID = mat2db(DB, s1, 'IsUnique', false, 'Tags', {'a/b/c','d/e/f/g'});
s2 = getdb(DB, 'datasets', 0);
s2.dataset_uuid = UUID{1};
s3 = getdb(DB, 'datasets', inf, s2, 'TagMatch', 'prefix','Tags', ...
    {{'a/','d/e/'}});
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s3));
assertEqual(1, length(s3));

function testPrefixMatchANDTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with tags that are a prefix match\n');
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
UUID = mat2db(DB, s1, 'IsUnique', false,'Tags', ...
    {'a/b/c','d/e/f/g'});
s2 = getdb(DB, 'datasets', 0);
s2.dataset_uuid = UUID{1};
s3 = getdb(DB, 'datasets', inf, s2, 'TagMatch', 'prefix','Tags', ...
    {{'a/'},{'d/e/'}});
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s3));
assertEqual(1, length(s3));

function testWordMatchTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with tags that are a word match\n');
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
UUID = mat2db(DB, s1, 'IsUnique', false, 'Tags', 'a/b/c');
s2 = getdb(DB, 'datasets', 0);
s2.dataset_uuid = UUID{1};
s3 = getdb(DB, 'datasets', inf, s2, 'TagMatch', 'word','Tags', ...
    {{'c'}});
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s3));
assertEqual(1, length(s3));

function testWordMatchORTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with tags that are a word match\n');
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
UUID = mat2db(DB, s1, 'IsUnique', false, 'Tags', {'a/b/c','d/e/f/g'});
s2 = getdb(DB, 'datasets', 0);
s2.dataset_uuid = UUID{1};
s3 = getdb(DB, 'datasets', inf, s2, 'TagMatch', 'word','Tags', ...
    {{'a','g/'}});
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s3));
assertEqual(1, length(s3));

function testWordMatchANDTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with tags that are a prefix match\n');
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
UUID = mat2db(DB, s1, 'IsUnique', false,'Tags', ...
    {'a/b/c','d/e/f/g'});
s2 = getdb(DB, 'datasets', 0);
s2.dataset_uuid = UUID{1};
s3 = getdb(DB, 'datasets', inf, s2, 'TagMatch', 'word','Tags', ...
    {{'c'},{'d'}});
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s3));
assertEqual(1, length(s3));