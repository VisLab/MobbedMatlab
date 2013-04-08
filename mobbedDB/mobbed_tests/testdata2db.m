function test_suite = testdata2db  %#ok<STOUT>
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

function testNumericStream(tStruct) %#ok<DEFNU>
fprintf('It should store additional data that is a numeric stream\n');
DB = tStruct.DB;
load EEG.mat;
sdef = db2data(DB);        
sdef.datadef_format = 'NUMERIC_STREAM';
sdef.datadef_sampling_rate = EEG.srate;
sdef.data = EEG.data;
sdef.datadef_description = [EEG.setname ' ' EEG.filename ' numeric stream'];
UUIDs = data2db(DB, sdef);            
assertTrue(iscellstr(UUIDs));
assertTrue(~isempty(UUIDs{1}));

function testNumeric(tStruct) %#ok<DEFNU>
fprintf('It should store additional data that is numeric\n');
DB = tStruct.DB;
load EEG.mat;
sdef = db2data(DB);        
sdef.datadef_format = 'NUMERIC_VALUE';
sdef.data = EEG.data(1,:);
sdef.datadef_description = [EEG.setname ' ' EEG.filename ' numeric'];
UUIDs = data2db(DB, sdef);        
% check that data def UUID(s) have been generated 
assertTrue(iscellstr(UUIDs));
assertTrue(~isempty(UUIDs{1}));

function testExternal(tStruct) %#ok<DEFNU>
fprintf('It should store additional data that is a file\n');
DB = tStruct.DB;
load EEG.mat;
sdef = db2data(DB);        
sdef.datadef_format = 'EXTERNAL';
sdef.data = EEG.data;
sdef.datadef_description = [EEG.setname ' ' EEG.filename ' external'];
UUIDs = data2db(DB, sdef);            
% check that data def UUID(s) have been generated 
assertTrue(iscellstr(UUIDs));
assertTrue(~isempty(UUIDs{1}));

function testXML(tStruct) %#ok<DEFNU>
fprintf('It should store additional data that is xml\n');
DB = tStruct.DB;
sdef = db2data(DB);         
sdef.datadef_format = 'XML_VALUE';
sdef.data = xmlwrite(which('sample.xml'));
sdef.datadef_description = 'xml';
UUIDs = data2db(DB, sdef);           
assertTrue(iscellstr(UUIDs));
assertTrue(~isempty(UUIDs{1}));
