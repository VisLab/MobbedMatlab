function test_suite = testCursors %#ok<STOUT>
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

function testCursor(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with cursor:\n');
fprintf('It should retrieve datasets using a cursor\n');
DB = tStruct.DB;
dataset = getdb(DB, 'datasets', 0);
for a = 1:50
    dataset.dataset_name = ['cursor_dataset' num2str(a)];
    putdb(DB, 'datasets', dataset);
end
commit(DB);
tempdataset.dataset_name = 'cursor_dataset*';
fprintf(['--It should retrieve the same number of rows as the limit' ...
    ' 30\n'])
s1 = getdb(DB, 'datasets', 30, tempdataset, 'RegExp', 'on', ...
    'DataCursor', 'dataset_cursor');
assertEqual(length(s1), 30);
fprintf(['--It should retrieve 20 rows which is less than the limit' ...
    ' 30\n'])
s2 = getdb(DB, 'datasets', 30, 'RegExp', 'on', ...
    'DataCursor', 'dataset_cursor');
assertEqual(length(s2), 20);

function testCloseCursor(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for close with cursor that exists:\n');
fprintf('It should close a cursor that exists\n');
DB = tStruct.DB;
dataset = getdb(DB, 'datasets', 0);
for a = 1:50
    dataset.dataset_name = ['close_dataset' num2str(a)];
    putdb(DB, 'datasets', dataset);
end
commit(DB);
tempdataset.dataset_name = 'close_dataset*';
fprintf(['--It should retrieve the same number of rows as the limit' ...
    ' 30\n'])
s1 = getdb(DB, 'datasets', 30, tempdataset, 'RegExp', 'on', ...
    'DataCursor', 'close_cursor');
assertEqual(length(s1), 30);
close(DB, 'DataCursor', 'close_cursor')
fprintf(['--It should retrieve the same number of rows as the limit' ...
    ' 30\n'])
s2 = getdb(DB, 'datasets', 30, 'RegExp', 'on', ...
    'DataCursor', 'close_cursor');
assertEqual(length(s2), 30);

function testCloseInvalidCursor(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for close with cursor that does not exist:\n');
fprintf(['It should throw an exception when closing a cursor that does' ...
    ' not exist\n']);
DB = tStruct.DB;
fprintf(['--It should throw an exception because the cursor does not' ...
    ' exist\n'])
assertExceptionThrown(@() error(close(DB, 'DataCursor', ...
    'invalid_cursor')), 'MATLAB:maxlhs');
