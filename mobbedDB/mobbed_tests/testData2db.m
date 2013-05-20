function test_suite = testData2db  %#ok<STOUT>
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

function testNumericStream(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for data2db with numeric stream format:\n');
fprintf('It should store a datadef that is numeric stream format\n');
DB = tStruct.DB;
load eeg_data_ch1.mat;
sdef = db2data(DB);        
sdef.datadef_format = 'NUMERIC_STREAM';
sdef.datadef_sampling_rate = EEG.srate;
sdef.data = EEG.data;
sdef.datadef_description = 'numeric stream data';
UUIDs = data2db(DB, sdef);            
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));

function testNumericValue(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for data2db with numeric value format:\n');
fprintf('It should store a datadef that is numeric value format\n');
DB = tStruct.DB;
load eeg_data_ch1.mat;
sdef = db2data(DB);        
sdef.datadef_format = 'NUMERIC_VALUE';
sdef.data = EEG.data(1,:);
sdef.datadef_description = 'numeric value data';
UUIDs = data2db(DB, sdef);        
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));

function testExternal(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for data2db with external format:\n');
fprintf('It should store a datadef that is external format\n');
DB = tStruct.DB;
load eeg_data_ch1.mat;
sdef = db2data(DB);        
sdef.datadef_format = 'EXTERNAL';
sdef.data = EEG.data;
sdef.datadef_description = 'external data';
UUIDs = data2db(DB, sdef);            
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));

function testXMLValue(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for data2db with xml value format:\n');
fprintf('It should store a datadef that is xml value format\n');
DB = tStruct.DB;
sdef = db2data(DB);         
sdef.datadef_format = 'XML_VALUE';
sdef.data = '<xml> <tag1> </tag1> </xml>';
sdef.datadef_description = 'xml value data';
UUIDs = data2db(DB, sdef);           
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
