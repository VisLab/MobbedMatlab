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

% Function executed after each test
function teardown(~) %#ok<DEFNU>
try
    Mobbed.closeAll();
catch ME %#ok<NASGU>
end

function testElements(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for storing a generic modality dataset that only' ...
    ' has elements:\n']);
fprintf(['It should store a generic modality dataset that only has' ...
    ' elements\n']);
DB = tStruct.DB;
generic = genericTestClass(5, 0, [], 0, 0);
s1 = db2mat(DB);
s1.dataset_name = 'generic elements only';
s1.data = generic.data;
s1.dataset_modality_uuid = tStruct.mUUID;
UUIDs = mat2db(DB, s1, 'IsUnique', false);
s2 = db2mat(DB, UUIDs);
fprintf('--It should return a dataset with a element field\n');
assertTrue(isfield(s2.data, 'element'));
fprintf('--It should return a dataset that is equal\n');
assertTrue(isequal(s1.data,s2.data));

function testElementsEvents(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for storing a generic modality dataset that' ...
    ' has elements and events:\n']);
fprintf('It should store a generic dataset with elements and events\n');
DB = tStruct.DB;
generic = genericTestClass(5, 5, [], 0, 0);
s1 = db2mat(DB);
s1.dataset_name = 'generic elements and events';
s1.data = generic.data;
s1.dataset_modality_uuid = tStruct.mUUID;
UUIDs = mat2db(DB, s1, 'IsUnique', false);
s2 = db2mat(DB, UUIDs);
fprintf('--It should return a dataset with a element field\n');
assertTrue(isfield(s2.data, 'element'));
fprintf('--It should return a dataset with a event field\n');
assertTrue(isfield(s2.data, 'event'));
fprintf('--It should return a dataset that is equal\n');
assertTrue(isequal(s1.data,s2.data));

function testElementsEventsFeatures(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for storing a generic modality dataset that' ...
    ' has elements, events, and metadata:\n']);
fprintf(['It should store a generic dataset with elements, events,' ...
    ' and metadata\n']);
DB = tStruct.DB;
generic = genericTestClass(5, 5, 'NUMERIC_STREAM', 0, 0);
s1 = db2mat(DB);
s1.dataset_name = 'generic elements and events';
s1.data = generic.data;
s1.dataset_modality_uuid = tStruct.mUUID;
UUIDs = mat2db(DB, s1, 'IsUnique', false);
s2 = db2mat(DB, UUIDs);
fprintf('--It should return a dataset with a element field\n');
assertTrue(isfield(s2.data, 'element'));
fprintf('--It should return a dataset with a event field\n');
assertTrue(isfield(s2.data, 'event'));
fprintf('--It should return a dataset with a feature field\n');
assertTrue(isfield(s2.data, 'feature'));
fprintf('--It should return a dataset that is equal\n');
assertTrue(isequal(s1.data,s2.data));

function testElementsEventsFeaturesMetadataExtras(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for storing a generic modality dataset that' ...
    ' has elements, events, metadata, and extra fields:\n']);
fprintf(['It should store a generic dataset with elements, events,' ...
    ' metadata, and extra fields\n']);
DB = tStruct.DB;
generic = genericTestClass(5, 5, 'NUMERIC_STREAM', 5, 5);
s1 = db2mat(DB);
s1.dataset_name = 'generic elements, events, metadata, and extra fields';
s1.data = generic.data;
s1.dataset_modality_uuid = tStruct.mUUID;
UUIDs = mat2db(DB, s1, 'IsUnique', false);
s2 = db2mat(DB, UUIDs);
fprintf('--It should return a dataset with a element field\n');
assertTrue(isfield(s2.data, 'element'));
fprintf('--It should return a dataset with a event field\n');
assertTrue(isfield(s2.data, 'event'));
fprintf('--It should return a dataset with a feature field\n');
assertTrue(isfield(s2.data, 'feature'));
fprintf('--It should return a dataset with a metadata field\n');
assertTrue(isfield(s2.data, 'metadata'));
fprintf('--It should return a dataset that is equal\n');
assertTrue(isequal(s1.data,s2.data));