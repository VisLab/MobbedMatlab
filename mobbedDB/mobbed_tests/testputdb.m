function test_suite = testputdb %#ok<STOUT>
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
% Create reference tables
d = getdb(DB, 'datadefs', 0);
d.datadef_format = 'EXTERNAL';
d.datadef_sampling_rate = 128;
d.datadef_description = 'data def description';
datadef_uuid = putdb(DB, 'datadefs', d);
tStruct.datadef_uuid = datadef_uuid{1};

d = getdb(DB, 'datasets', 0);
d.dataset_name = randseq(20);
d.dataset_description = 'reference dataset description ';
dataset_uuid = putdb(DB, 'datasets', d);
tStruct.dataset_uuid = dataset_uuid{1};

e = getdb(DB, 'elements', 0);
e.element_label = 'reference element';
e.element_organizational_uuid = tStruct.dataset_uuid;
e.element_organizational_class = 'datasets';
e.element_position = 1;
e.element_description = 'reference element position';
element_uuid = putdb(DB, 'elements', e);
tStruct.element_uuid = element_uuid{1};

e = getdb(DB, 'event_types', 0);
e.event_type = 'referece type';
e.event_type_description = 'referece type description';
event_type_uuid = putdb(DB, 'event_types', e);
tStruct.event_type_uuid = event_type_uuid{1};

s = getdb(DB, 'structures', 0);
s.structure_name = 'parent';
s.structure_path = '/EEG';
structure_uuid = putdb(DB, 'structures', s);
tStruct.structure_uuid = structure_uuid{1};

DB.commit();
tStruct.DB = DB;

function teardown(tStruct) %#ok<DEFNU>
% Function executed after each test
try
    tStruct.DB.close();
catch ME %#ok<NASGU>
end

function testputdbAttributes(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with attributes:\n');
fprintf('It should store a single attribute\n');
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
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testputdbCollections(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with collections:\n');
fprintf('It should store a single collection\n');
DB = tStruct.DB;
c1 = getdb(DB, 'collections', 0);
c1.collection_uuid = tStruct.dataset_uuid; 
c1.collection_entity_uuid = tStruct.element_uuid;
c1.collection_entity_class = 'elements';
UUIDs = putdb(DB, 'collections', c1);
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testputdbComments(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with comments:\n');
fprintf('It should store a single comment\n');
DB = tStruct.DB;
c1 = getdb(DB, 'comments', 0);
c1.comment_entity_uuid = tStruct.dataset_uuid;
c1.comment_entity_class = 'datasets';
c1.comment_value = 'test comment value';
UUIDs = putdb(DB, 'comments', c1);
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testputdbContacts(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with contacts:\n');
fprintf('It should store a single contact\n');
DB = tStruct.DB;
c1 = getdb(DB, 'contacts', 0);  % Get the template structure for upload
c1.contact_first_name = 'Test';
c1.contact_last_name = 'Contact';
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
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testputdbDatadefs(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with datadefs:\n');
fprintf('It should store a single datadef\n');
DB = tStruct.DB;
d1 = getdb(DB, 'datadefs', 0);
d1.datadef_format = 'EXTERNAL';
d1.datadef_sampling_rate = 128;
d1.datadef_description = 'test data def description';
UUIDs = putdb(DB, 'datadefs', d1);
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testputdbDatamaps(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with datamaps:\n');
fprintf('It should store a single datamap\n');
DB = tStruct.DB;
d1 = getdb(DB, 'datamaps', 0);
d1.datamap_def_uuid = tStruct.datadef_uuid;
d1.datamap_entity_uuid = tStruct.dataset_uuid;
d1.datamap_entity_class = 'datasets';
d1.datamap_path = 'test path';
UUIDs = putdb(DB, 'datamaps', d1);
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testputdbDatasets(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with datasets:\n');
fprintf('It should store a single dataset\n');
DB = tStruct.DB;
d1 = getdb(DB, 'datasets', 0);
d1.dataset_name = randseq(20);
d1.dataset_description = 'reference dataset description ';
UUIDs = putdb(DB, 'datasets', d1);
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testputdbDevices(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with devices:\n');
fprintf('It should store a single device\n');
DB = tStruct.DB;
d1 = getdb(DB, 'devices', 0);
d1.device_description = 'test device description';
UUIDs = putdb(DB, 'devices', d1);
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testputdbElements(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with elements:\n');
fprintf('It should store a single element\n');
DB = tStruct.DB;
e1 = getdb(DB, 'elements', 0);
e1.element_label = 'test element';
e1.element_parent_uuid = tStruct.element_uuid;
e1.element_position = 1;
e1.element_description = 'test element description';
UUIDs = putdb(DB, 'elements', e1);
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testputdbEvents(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with events:\n');
fprintf('It should store a single event\n');
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
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testputdbEventTypes(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with event types:\n');
fprintf('It should store a single event type\n');
DB = tStruct.DB;
e1 = getdb(DB, 'event_types', 0);
e1.event_type = 'test event type';
e1.event_type_description = 'test event type description';
UUIDs = putdb(DB, 'event_types', e1);
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testputdbModalities(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with modalities:\n');
fprintf('It should store a single modality\n');
DB = tStruct.DB;
m1 = getdb(DB, 'modalities', 0);
m1.modality_name = randseq(20);
m1.modality_platform = 'matlab';
m1.modality_description = 'test modality description';
UUIDs = putdb(DB, 'modalities', m1);
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testputdbStructures(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with structures:\n');
fprintf('It should store a single structure\n');
DB = tStruct.DB;
s1 = getdb(DB, 'structures', 0);
s1.structure_name = 'parent';
s1.structure_path = '/EEG';
UUIDs = putdb(DB, 'structures', s1);
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testputdbSubjects(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with subjects:\n');
fprintf('It should store a single subject\n');
DB = tStruct.DB;
s1 = getdb(DB, 'subjects', 0);
s1.subject_description = 'test subject description';
UUIDs = putdb(DB, 'subjects', s1);
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testputdbTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with tags:\n');
fprintf('It should store a single tag\n');
DB = tStruct.DB;
t1 = getdb(DB, 'tags', 0);
t1.tag_name = 'test tag';
t1.tag_entity_uuid = tStruct.dataset_uuid;
t1.tag_entity_class = 'datasets';
UUIDs = putdb(DB, 'tags', t1);
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();

function testputdbTransforms(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for putdb with transforms:\n');
fprintf('It should store a single transform\n');
DB = tStruct.DB;
t1 = getdb(DB, 'transforms', 0);
t1.transform_uuid = tStruct.dataset_uuid;
t1.transform_string = randseq(20);
t1.transform_description = 'test transform description';
UUIDs = putdb(DB, 'transforms', t1);
fprintf('--It should return a cellstr containing one uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));
DB.commit();


