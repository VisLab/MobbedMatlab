function test_suite = testGENERIC %#ok<STOUT>
initTestSuite;

function tStruct = setup %#ok<DEFNU>
tStruct = struct('name', 'testdb', 'url', 'localhost', ...
    'user', 'postgres', 'password', 'admin', 'DB', []);
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

m = getdb(DB, 'modalities', inf);
mNames = {m.modality_name};
pos = strcmp('GENERIC', mNames);
uuids = {m.modality_uuid};
tStruct.mUUID = uuids{pos};

function teardown(tStruct) %#ok<DEFNU>
% Function executed after each test
try
    tStruct.DB.close();
catch ME %#ok<NASGU>
end

function testGenericElements(tStruct)
fprintf('\nIt should store a generic dataset with only elements\n');
DB = tStruct.DB;
generic = genericTestClass(5, 0, 0, 0, 0);
s1 = db2mat(DB);
s1.dataset_name = 'GENERIC - elements only';
s1.data = generic.data;
s1.dataset_modality_uuid = tStruct.mUUID;
sUUID = mat2db(DB, s1, false);
s2 = db2mat(DB, sUUID);
assertTrue(isequal(s1.data,s2.data));

function testGenericElementsEvents(tStruct)
fprintf('\nIt should store a generic dataset with elements and events\n');
DB = tStruct.DB;
generic = genericTestClass(5, 5, 0, 0, 0);
s1 = db2mat(DB);
s1.dataset_name = 'GENERIC - elements and events';
s1.data = generic.data;
s1.dataset_modality_uuid = tStruct.mUUID;
sUUID = mat2db(DB, s1, false);
s2 = db2mat(DB, sUUID);
assertTrue(isequal(s1.data,s2.data));

function testGenericElementsEventsMetadata(tStruct)
fprintf('\nIt should store a generic dataset with elements, events, and metadata\n');
DB = tStruct.DB;
generic = genericTestClass(5, 5, 5, 0, 0);
s1 = db2mat(DB);
s1.dataset_name = 'GENERIC - elements and events';
s1.data = generic.data;
s1.dataset_modality_uuid = tStruct.mUUID;
sUUID = mat2db(DB, s1, false);
s2 = db2mat(DB, sUUID);
assertTrue(isequal(s1.data,s2.data));

function testGenericElementsEventsMetadataExtras(tStruct)
fprintf('\nIt should store a generic dataset with elements, events, metadata, and extra fields\n');
DB = tStruct.DB;
generic = genericTestClass(5, 5, 5, 5, 0);
s1 = db2mat(DB);
s1.dataset_name = 'GENERIC - elements and events';
s1.data = generic.data;
s1.dataset_modality_uuid = tStruct.mUUID;
sUUID = mat2db(DB, s1, false);
s2 = db2mat(DB, sUUID);
assertTrue(isequal(s1.data,s2.data));

