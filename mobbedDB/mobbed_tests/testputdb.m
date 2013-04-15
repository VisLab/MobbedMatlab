function test_suite = testPutdb %#ok<STOUT>
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

function teardown(tStruct) %#ok<DEFNU>
% Function executed after each test
try
    tStruct.DB.close();
catch ME %#ok<NASGU>
end

function testPutdbAttributes(tStruct) %#ok<DEFNU>
fprintf('\nIt should save a attribute\n');
DB = tStruct.DB;
a1 = getdb(DB, 'attributes', 0);
a1.attribute_entity_uuid = randomTestClass.generateRandomUUID;
a1.attribute_organizational_uuid = randomTestClass.generateRandomUUID;
a1.attribute_structure_uuid = randomTestClass.generateRandomUUID;
a1.attribute_numeric_value = 1;
a1.attribute_value = 'attribute value: attribute 1';
putdb(DB, 'attributes', a1);
DB.commit();

function testPutdbComments(tStruct) %#ok<DEFNU>
fprintf('\nIt should save a comment\n');
DB = tStruct.DB;
c1 = getdb(DB, 'comments', 0);  % Get the template structure for upload
c1.comment_entity_class = 34;
c1.comment_entity_uuid = randomTestClass.generateRandomUUID;
c1.comment_contact_uuid = randomTestClass.generateRandomUUID;
c1.comment_value = 'comment value: comment 1';
putdb(DB, 'comments', c1);
DB.commit();

function testPutdbContacts(tStruct) %#ok<DEFNU>
fprintf('\nIt should save a contact\n');
DB = tStruct.DB;
c1 = getdb(DB, 'contacts', 0);  % Get the template structure for upload
c1.contact_first_name = 'Contact';
c1.contact_last_name = 'One';
c1.contact_middle_initial = 'Z';
c1.contact_address_line_1 = '8524 Dummy Address 1';
c1.contact_address_line_2 = '1234 Dummy Address 2';
c1.contact_city ='Miami';
c1.contact_state = 'Florida';
c1.contact_country = 'United States';
c1.contact_postal_code = '42486';
c1.contact_telephone = '124-157-4574';
c1.contact_email = 'c1@email.com';
putdb(DB, 'contacts', c1);
DB.commit();

function testPutdbDataDefs(tStruct) %#ok<DEFNU>
fprintf('\nIt should save a data def\n');
DB = tStruct.DB;
d1 = getdb(DB, 'datadefs', 0);
d1.datadef_format = 55;
d1.datadef_sampling_rate = 256;
d1.datadef_description = 'data def description: data def 1';
putdb(DB, 'datadefs', d1);
DB.commit();

function testPutdbDataMaps(tStruct) %#ok<DEFNU>
fprintf('\nIt should save a data map\n');
DB = tStruct.DB;
d1 = getdb(DB, 'datamaps', 0);
d1.datamap_def_uuid = randomTestClass.generateRandomUUID;
d1.datamap_entity_uuid = randomTestClass.generateRandomUUID;
d1.datamap_structure_uuid = randomTestClass.generateRandomUUID;
putdb(DB, 'datamaps', d1);
DB.commit();

function testPutdbElements(tStruct) %#ok<DEFNU>
fprintf('\nIt should save a element\n');
DB = tStruct.DB;
e1 = getdb(DB, 'elements', 0);
e1.element_label = 'element label: element 1';
e1.element_parent_uuid = randomTestClass.generateRandomUUID;
e1.element_position = 1;
e1.element_description = 'element description: element 1';
putdb(DB, 'elements', e1);
DB.commit();

function testPutdbEvents(tStruct) %#ok<DEFNU>
fprintf('\nIt should save a event\n');
DB = tStruct.DB;
e1 = getdb(DB, 'events', 0);
e1.event_entity_uuid = randomTestClass.generateRandomUUID;
e1.event_type_uuid = randomTestClass.generateRandomUUID;
e1.event_start_time = 200;
e1.event_end_time = 200;
e1.event_position = 1;
e1.event_certainty = 1;
putdb(DB, 'events', e1);
DB.commit();

function testPutdbEventTypes(tStruct) %#ok<DEFNU>
fprintf('\nIt should save a event type\n');
DB = tStruct.DB;
e1 = getdb(DB, 'event_types', 0);
e1.event_type = 'event type: event type 1';
e1.event_type_description = 'event type description: event type 1';
putdb(DB, 'event_types', e1);
DB.commit();

function testPutdbModalities(tStruct) %#ok<DEFNU>
fprintf('\nIt should save a modality\n');
DB = tStruct.DB;
m1 = getdb(DB, 'modalities', 0);
m1.modality_name = 'modality name: modality 1';
m1.modality_platform = 'modality platform: modality 1';
m1.modality_description = 'modality description: modality 1';
putdb(DB, 'modalities', m1);
DB.commit();

function testPutdbTags(tStruct) %#ok<DEFNU>
fprintf('\nIt should save a tag\n');
DB = tStruct.DB;
t1 = getdb(DB, 'tags', 0);  % Get the template structure for upload
t1.tag_name = 'test tag';
t1.tag_entity_uuid = randomTestClass.generateRandomUUID;
t1.tag_entity_class = 45;
putdb(DB, 'tags', t1);
DB.commit();
