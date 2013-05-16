function test_suite = testPutdb %#ok<STOUT>
initTestSuite;

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

% Create reference tables
d = getdb(DB, 'datadefs', 0);
d.datadef_format = 'EXTERNAL';
d.datadef_sampling_rate = 128;
d.datadef_description = 'data def description';
UUID = putdb(DB, 'datadefs', d);
tStruct.datadef_uuid = UUID{1};

d = getdb(DB, 'datasets', 0);
d.dataset_name = randomClass.generateString;
d.dataset_description = 'reference dataset description ';
UUID = putdb(DB, 'datasets', d);
tStruct.dataset_uuid = UUID{1};

e = getdb(DB, 'elements', 0);
e.element_label = 'reference element';
e.element_organizational_uuid = tStruct.dataset_uuid;
e.element_organizational_class = 'datasets';
e.element_position = 1;
e.element_description = 'reference element position';
UUID = putdb(DB, 'elements', e);
tStruct.element_uuid = UUID{1};

e = getdb(DB, 'event_types', 0);
e.event_type = 'referece type';
e.event_type_description = 'referece type description';
UUID = putdb(DB, 'event_types', e);
tStruct.event_type_uuid = UUID{1};

s = getdb(DB, 'structures', 0);
s.structure_name = 'EEG';
s.structure_path = '/EEG';
UUID = putdb(DB, 'structures', s);
tStruct.structure_uuid = UUID{1};

DB.commit();
tStruct.DB = DB;

function teardown(tStruct) %#ok<DEFNU>
% Function executed after each test
try
    tStruct.DB.close();
catch ME %#ok<NASGU>
end

function testAttributes(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with attributes:\n');

fprintf('It should store a attribute\n');
DB = tStruct.DB;
a1 = getdb(DB, 'attributes', 0);
a1.attribute_entity_uuid = tStruct.element_uuid;
a1.attribute_entity_class = 'elements';
a1.attribute_organizational_uuid = tStruct.dataset_uuid;
a1.attribute_organizational_class = 'datasets';
a1.attribute_structure_uuid = tStruct.structure_uuid;
a1.attribute_numeric_value = 1;
a1.attribute_value = '1';
UUIDs = putdb(DB, 'attributes', a1);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

fprintf('It should update a attribute\n');
a2 = getdb(DB, 'attributes', 0);
a2.attribute_uuid = UUIDs{1};
a2 = getdb(DB, 'attributes', 1, a2);
a2.attribute_numeric_value = 2;
a2.attribute_value = '2';
UUIDs  = putdb(DB, 'attributes', a2);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testCollections(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with collections:\n');

fprintf('It should store a collection\n');
DB = tStruct.DB;
c1 = getdb(DB, 'collections', 0);
c1.collection_uuid = tStruct.dataset_uuid;
c1.collection_entity_uuid = tStruct.element_uuid;
c1.collection_entity_class = 'elements';
UUIDs = putdb(DB, 'collections', c1);
fprintf(['--It should return a cell array containing two comma' ...
    ' separated string uuids\n']);
assertTrue(iscellstr(UUIDs));
UUIDs = regexp(UUIDs{1}, ',', 'split');
assertEqual(2, length(UUIDs));
DB.commit();

fprintf('It should update a collection\n');
c2 = getdb(DB, 'collections', 0);
c2.collection_uuid = UUIDs{1};
c2.collection_entity_uuid = UUIDs{2};
c2 = getdb(DB, 'collections', 1, c2);
c2.collection_entity_uuid = tStruct.structure_uuid;
c2.collection_entity_class = 'structures';
UUIDs  = putdb(DB, 'collections', c2);
fprintf(['--It should return a cell array containing two comma' ...
    ' separated string uuids\n']);
assertTrue(iscellstr(UUIDs));
UUIDs = regexp(UUIDs{1}, ',', 'split');
assertEqual(2, length(UUIDs));
DB.commit();

function testComments(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with comments:\n');

fprintf('It should store a comment\n');
DB = tStruct.DB;
c1 = getdb(DB, 'comments', 0);
c1.comment_entity_uuid = tStruct.dataset_uuid;
c1.comment_entity_class = 'datasets';
c1.comment_value = 'test comment value';
UUIDs = putdb(DB, 'comments', c1);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

fprintf('It should update a comment\n');
c2 = getdb(DB, 'comments', 0);
c2.comment_uuid = UUIDs{1};
c2 = getdb(DB, 'comments', 1, c2);
c2.comment_entity_uuid = tStruct.structure_uuid;
c2.comment_entity_class = 'structures';
UUIDs  = putdb(DB, 'comments', c2);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testContacts(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with contacts:\n');

fprintf('It should store a contact\n');
DB = tStruct.DB;
c1 = getdb(DB, 'contacts', 0);
c1.contact_first_name = 'John';
c1.contact_last_name = 'Doe';
c1.contact_middle_initial = 'Z';
c1.contact_address_line_1 = '8524 Dummy Address 1';
c1.contact_address_line_2 = '1234 Dummy Address 2';
c1.contact_city ='Miami';
c1.contact_state = 'Florida';
c1.contact_country = 'United States';
c1.contact_postal_code = '42486';
c1.contact_telephone = '124-157-4574';
c1.contact_email = 'c1@email.com';
UUIDs = putdb(DB, 'contacts', c1);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

fprintf('It should update a contact\n');
c2 = getdb(DB, 'contacts', 0);
c2.contact_uuid = UUIDs{1};
c2 = getdb(DB, 'contacts', 1, c2);
c2.contact_first_name = 'Jane';
UUIDs  = putdb(DB, 'contacts', c2);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();


function testDatadefs(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with datadefs:\n');

fprintf('It should store a datadef\n');
DB = tStruct.DB;
d1 = getdb(DB, 'datadefs', 0);
d1.datadef_format = 'EXTERNAL';
d1.datadef_sampling_rate = 128;
d1.datadef_description = 'test data def description';
UUIDs = putdb(DB, 'datadefs', d1);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

fprintf('It should update a datadef\n');
d2 = getdb(DB, 'datadefs', 0);
d2.datadef_uuid = UUIDs{1};
d2 = getdb(DB, 'datadefs', 1, d2);
d2.datadef_sampling_rate = 256;
UUIDs  = putdb(DB, 'datadefs', d2);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testDatamaps(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with datamaps:\n');

fprintf('It should store a datamap\n');
DB = tStruct.DB;
d1 = getdb(DB, 'datamaps', 0);
d1.datamap_def_uuid = tStruct.datadef_uuid;
d1.datamap_entity_uuid = tStruct.dataset_uuid;
d1.datamap_entity_class = 'datasets';
d1.datamap_path = '/EEG/dataEx';
UUIDs = putdb(DB, 'datamaps', d1);
fprintf(['--It should return a cell array containing two comma' ...
    ' separated string uuids\n']);
assertTrue(iscellstr(UUIDs));
UUIDs = regexp(UUIDs{1}, ',', 'split');
assertEqual(2, length(UUIDs));
DB.commit();

fprintf('It should update a datamap\n');
d2 = getdb(DB, 'datamaps', 0);
d2.datamap_def_uuid = UUIDs{1};
d2.datamap_entity_uuid = UUIDs{2};
d2 = getdb(DB, 'datamaps', 1, d2);
d2.datamap_path = '/EEG/dataEx2';
UUIDs  = putdb(DB, 'datamaps', d2);
fprintf(['--It should return a cell array containing two comma' ...
    ' separated string uuids\n']);
assertTrue(iscellstr(UUIDs));
UUIDs = regexp(UUIDs{1}, ',', 'split');
assertEqual(2, length(UUIDs));
DB.commit();

function testDatasets(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with datasets:\n');

fprintf('It should store a dataset\n');
DB = tStruct.DB;
d1 = getdb(DB, 'datasets', 0);
d1.dataset_name = randomClass.generateString;
UUIDs = putdb(DB, 'datasets', d1);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

fprintf('It should update a dataset\n');
d2 = getdb(DB, 'datasets', 0);
d2.dataset_uuid = UUIDs{1};
d2 = getdb(DB, 'datasets', 1, d2);
d2.dataset_description = 'update dataset description ';
UUIDs  = putdb(DB, 'datasets', d2);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testDevices(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with devices:\n');

fprintf('It should store a device\n');
DB = tStruct.DB;
d1 = getdb(DB, 'devices', 0);
d1.device_description = 'test device description';
UUIDs = putdb(DB, 'devices', d1);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

fprintf('It should update a device\n');
d2 = getdb(DB, 'devices', 0);
d2.device_uuid = UUIDs{1};
d2 = getdb(DB, 'devices', 1, d2);
d2.device_description = 'update device description ';
UUIDs  = putdb(DB, 'devices', d2);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testElements(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with elements:\n');
fprintf('It should store a element\n');
DB = tStruct.DB;
e1 = getdb(DB, 'elements', 0);
e1.element_label = 'test element';
e1.element_parent_uuid = tStruct.element_uuid;
e1.element_position = 1;
e1.element_description = 'test element description';
UUIDs = putdb(DB, 'elements', e1);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

fprintf('It should update a element\n');
e2 = getdb(DB, 'elements', 0);
e2.element_uuid = UUIDs{1};
e2 = getdb(DB, 'elements', 1, e2);
e2.element_description = 'update element description ';
UUIDs  = putdb(DB, 'elements', e2);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testEvents(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with events:\n');

fprintf('It should store a event\n');
DB = tStruct.DB;
e1 = getdb(DB, 'events', 0);
e1.event_entity_uuid = tStruct.dataset_uuid;
e1.event_entity_class = 'datasets';
e1.event_type_uuid = tStruct.event_type_uuid;
e1.event_start_time = 0;
e1.event_end_time = 1;
e1.event_position = 1;
e1.event_certainty = 1;
UUIDs = putdb(DB, 'events', e1);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

fprintf('It should update a event\n');
e2 = getdb(DB, 'events', 0);
e2.event_uuid = UUIDs{1};
e2 = getdb(DB, 'events', 1, e2);
e2.event_certainty = 0;
UUIDs  = putdb(DB, 'events', e2);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testEventTypes(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with event types:\n');

fprintf('It should store a event type\n');
DB = tStruct.DB;
e1 = getdb(DB, 'event_types', 0);
e1.event_type = 'test event type';
e1.event_type_description = 'test event type description';
UUIDs = putdb(DB, 'event_types', e1);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

fprintf('It should update a event type\n');
e2 = getdb(DB, 'event_types', 0);
e2.event_type_uuid = UUIDs{1};
e2 = getdb(DB, 'event_types', 1, e2);
e2.event_type_description = 'update event type description';
UUIDs  = putdb(DB, 'event_types', e2);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testModalities(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with modalities:\n');

fprintf('It should store a modality\n');
DB = tStruct.DB;
m1 = getdb(DB, 'modalities', 0);
m1.modality_name = randomClass.generateString;
m1.modality_platform = 'matlab';
m1.modality_description = 'test modality description';
UUIDs = putdb(DB, 'modalities', m1);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

fprintf('It should update a modality\n');
m2 = getdb(DB, 'modalities', 0);
m2.modality_uuid = UUIDs{1};
m2 = getdb(DB, 'modalities', 1, m2);
m2.modality_description = 'update modality description';
UUIDs  = putdb(DB, 'modalities', m2);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testStructures(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with structures:\n');

fprintf('It should store a structure\n');
DB = tStruct.DB;
s1 = getdb(DB, 'structures', 0);
s1.structure_name = 'chanlocs';
s1.structure_path = '/EEG/chalocs';
s1.structure_parent_uuid = tStruct.structure_uuid;
UUIDs = putdb(DB, 'structures', s1);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

fprintf('It should update a structure\n');
s2 = getdb(DB, 'structures', 0);
s2.structure_uuid = UUIDs{1};
s2 = getdb(DB, 'structures', 1, s2);
s2.structure_name = 'event';
s2.structure_path = '/EEG/event';
UUIDs  = putdb(DB, 'structures', s2);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testSubjects(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with subjects:\n');

fprintf('It should store a subject\n');
DB = tStruct.DB;
s1 = getdb(DB, 'subjects', 0);
s1.subject_description = 'test subject description';
UUIDs = putdb(DB, 'subjects', s1);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

fprintf('It should update a subject\n');
s2 = getdb(DB, 'subjects', 0);
s2.subject_uuid = UUIDs{1};
s2 = getdb(DB, 'subjects', 1, s2);
s2.subject_description = 'update subject description';
UUIDs  = putdb(DB, 'subjects', s2);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with tags:\n');

fprintf('It should store a tag\n');
DB = tStruct.DB;
t1 = getdb(DB, 'tags', 0);
t1.tag_name = 'test tag';
t1.tag_entity_uuid = tStruct.dataset_uuid;
t1.tag_entity_class = 'datasets';
UUIDs = putdb(DB, 'tags', t1);
fprintf(['--It should return a cell array containing two comma' ...
    ' separated string uuids\n']);
assertTrue(iscellstr(UUIDs));
UUIDs = regexp(UUIDs{1}, ',', 'split');
assertEqual(2, length(UUIDs));
DB.commit();

fprintf('It should update a tag\n');
t2 = getdb(DB, 'tags', 0);
t2.tag_name = UUIDs{1};
t2.tag_entity_uuid = UUIDs{2};
t2 = getdb(DB, 'tags', 1, t2);
t2.tag_name = 'update tag';
UUIDs  = putdb(DB, 'tags', t2);
fprintf(['--It should return a cell array containing two comma' ...
    ' separated string uuids\n']);
assertTrue(iscellstr(UUIDs));
UUIDs = regexp(UUIDs{1}, ',', 'split');
assertEqual(2, length(UUIDs));
DB.commit();

function testTransforms(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with transforms:\n');

fprintf('It should store a transform\n');
DB = tStruct.DB;
t1 = getdb(DB, 'transforms', 0);
t1.transform_uuid = tStruct.dataset_uuid;
t1.transform_string = randomClass.generateString;
t1.transform_description = 'test transform description';
UUIDs = putdb(DB, 'transforms', t1);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

fprintf('It should update a transform\n');
t2 = getdb(DB, 'transforms', 0);
t2.transform_uuid = UUIDs{1};
t2 = getdb(DB, 'transforms', 1, t2);
t2.transform_description = 'update transform description';
UUIDs  = putdb(DB, 'transforms', t2);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();
