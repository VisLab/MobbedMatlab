function test_suite = testdb2data  %#ok<STOUT>
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
fprintf('It should store additional data that is numeric stream format\n');
DB = tStruct.DB;
load EEG.mat;
sdef = db2data(DB);        
sdef.datadef_format = 'NUMERIC_STREAM';
sdef.datadef_sampling_rate = EEG.srate;
sdef.data = EEG.data;
sdef.datadef_description = [EEG.setname ' ' EEG.filename ' numeric stream'];
UUIDs = data2db(DB, sdef);            
sdef2 = db2data(DB, UUIDs);
assertTrue(isstruct(sdef2));
assertElementsAlmostEqual(sdef.data, sdef2.data);

function testNumericValue(tStruct) %#ok<DEFNU>
fprintf('It should store additional data that is numeric value format\n');
DB = tStruct.DB;
load EEG.mat;
sdef = db2data(DB);        
sdef.datadef_format = 'NUMERIC_VALUE';
sdef.data = EEG.data(1,:);
sdef.datadef_description = [EEG.setname ' ' EEG.filename ' numeric'];
UUIDs = data2db(DB, sdef);        
sdef2 = db2data(DB, UUIDs);
assertTrue(isstruct(sdef2));
assertElementsAlmostEqual(sdef.data, sdef2.data);

function testExternal(tStruct) %#ok<DEFNU>
fprintf('It should store additional data that is external format\n');
DB = tStruct.DB;
load EEG.mat;
sdef = db2data(DB);        
sdef.datadef_format = 'EXTERNAL';
sdef.data = EEG.data;
sdef.datadef_description = [EEG.setname ' ' EEG.filename ' external'];
UUIDs = data2db(DB, sdef);            
sdef2 = db2data(DB, UUIDs);
assertTrue(isstruct(sdef2));
assertTrue(~isempty(sdef2.datadef_oid));
assertTrue(isequal(sdef.data, sdef2.data));

function testXMLValue(tStruct) %#ok<DEFNU>
fprintf('It should store additional data that is xml value format\n');
DB = tStruct.DB;
sdef = db2data(DB);         
sdef.datadef_format = 'XML_VALUE';
sdef.data = xmlwrite(which('sample.xml'));
sdef.datadef_description = 'xml';
UUIDs = data2db(DB, sdef);           
sdef2 = db2data(DB, UUIDs);
assertTrue(isequal(sdef.data, sdef2.data));

