function test_suite = testdb2data  %#ok<STOUT>
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

function testdb2dataNumericStream(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for db2data with numeric stream format:\n');
fprintf('It should store a datadef that is numeric stream format\n');
DB = tStruct.DB;
load eeglab_data_ch.mat;
sdef = db2data(DB);
sdef.datadef_format = 'NUMERIC_STREAM';
sdef.datadef_sampling_rate = EEG.srate;
sdef.data = EEG.data;
sdef.datadef_description = [EEG.setname ' ' EEG.filename ' numeric stream'];
UUIDs = data2db(DB, sdef);
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
sdef2 = db2data(DB, UUIDs);
assertTrue(isstruct(sdef2));
fprintf('--It should retrieve a datadef that is equal to the stored datadef\n');
assertElementsAlmostEqual(sdef.data, sdef2.data);

function testdb2dataNumericValue(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for db2data with numeric value format:\n');
fprintf('It should store a datadef that is numeric value format\n');
DB = tStruct.DB;
load eeglab_data_ch.mat;
sdef = db2data(DB);
sdef.datadef_format = 'NUMERIC_VALUE';
sdef.data = EEG.data(1,:);
sdef.datadef_description = [EEG.setname ' ' EEG.filename ' numeric'];
UUIDs = data2db(DB, sdef);
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
sdef2 = db2data(DB, UUIDs);
assertTrue(isstruct(sdef2));
fprintf('--It should retrieve a datadef that is equal to the stored datadef\n');
assertElementsAlmostEqual(sdef.data, sdef2.data);

function testdb2dataExternal(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for db2data with external format:\n');
fprintf('It should store a datadef that is external format\n');
DB = tStruct.DB;
load eeglab_data_ch.mat;
sdef = db2data(DB);
sdef.datadef_format = 'EXTERNAL';
sdef.data = EEG.data;
sdef.datadef_description = [EEG.setname ' ' EEG.filename ' external'];
UUIDs = data2db(DB, sdef);
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
sdef2 = db2data(DB, UUIDs);
assertTrue(isstruct(sdef2));
fprintf('--It should retrieve a datadef with an oid\n');
assertTrue(~isempty(sdef2.datadef_oid));
fprintf('--It should retrieve a datadef that is equal to the stored datadef\n');
assertTrue(isequal(sdef.data, sdef2.data));

function testdb2dataXMLValue(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for db2data with xml value format:\n');
fprintf('It should store a datadef that is xml value format\n');
DB = tStruct.DB;
sdef = db2data(DB);
sdef.datadef_format = 'XML_VALUE';
sdef.data = xmlwrite(which('sample.xml'));
sdef.datadef_description = 'xml';
UUIDs = data2db(DB, sdef);
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
sdef2 = db2data(DB, UUIDs);
fprintf('--It should retrieve a datadef that is equal to the stored datadef\n');
assertTrue(isequal(sdef.data, sdef2.data));

