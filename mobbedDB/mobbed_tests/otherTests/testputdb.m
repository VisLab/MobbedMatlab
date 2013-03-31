function test_suite = testputdb %#ok<STOUT>
initTestSuite;

function tStruct = setup %#ok<DEFNU>
tStruct = struct('name', 'testdb', 'url', 'localhost', ...
    'user', 'postgres', 'password', 'admin', 'DB', []);
try
    DB = Mobbed(tStruct.name, tStruct.url, tStruct.user, tStruct.password);
catch ME %#ok<NASGU>
    Mobbed.createdb(tStruct.name, tStruct.url, tStruct.user, ...
        tStruct.password, 'mobbed.sql', false);
    DB = Mobbed(tStruct.name, tStruct.url, tStruct.user, tStruct.password);
end
tStruct.DB = DB;

function teardown(tStruct) %#ok<DEFNU>
% Function executed after each test
try
    tStruct.DB.close();
catch ME %#ok<NASGU>
end

function testAttributes_putdb(tStruct) %#ok<DEFNU>
fprintf('\nUnit test putdb function with attributes:\n');
fprintf('It should save an attribute\n');
DB = tStruct.DB;
a1 = getdb(DB, 'attributes', 0);
a1.attribute_entity_uuid = randomTestClass.generateRandomUUID;
a1.attribute_organizational_uuid = randomTestClass.generateRandomUUID;
a1.attribute_structure_uuid = randomTestClass.generateRandomUUID;
a1.attribute_position = 1;
a1.attribute_numeric_value = 1;
a1.attribute_value = 'attribute value: attribute 1';
putdb(DB, 'attributes', a1);

fprintf('It should save multiple attributes\n');
DB = tStruct.DB;
a3(1) = getdb(DB, 'attributes', 0);
a3(1).attribute_entity_uuid = randomTestClass.generateRandomUUID;
a3(1).attribute_organizational_uuid = randomTestClass.generateRandomUUID;
a3(1).attribute_structure_uuid = randomTestClass.generateRandomUUID;
a3(1).attribute_numeric_value = 2;
a3(1).attribute_value = 'attribute value: attribute 2';

a3(2) = getdb(DB, 'attributes', 0);
a3(2).attribute_entity_uuid = randomTestClass.generateRandomUUID;
a3(2).attribute_organizational_uuid = randomTestClass.generateRandomUUID;
a3(2).attribute_structure_uuid = randomTestClass.generateRandomUUID;
a3(2).attribute_numeric_value = 3;
a3(2).attribute_value = 'attribute value: attribute 3';

putdb(DB, 'attributes', a3);
DB.commit();

function testComments_putdb(tStruct) %#ok<DEFNU>
fprintf('\nUnit test putdb function with comments:\n');
fprintf('It should save a comment\n');
DB = tStruct.DB;
c1 = getdb(DB, 'comments', 0);  % Get the template structure for upload
c1.comment_entity_class = 34;
c1.comment_entity_uuid = randomTestClass.generateRandomUUID;
c1.comment_contact_uuid = randomTestClass.generateRandomUUID;
c1.comment_value = 'comment value: comment 1';
putdb(DB, 'comments', c1);
commit(DB);

fprintf('It should save multiple comments\n');
DB = tStruct.DB;
c3(1) = getdb(DB, 'comments', 0);  % Get the template structure for upload
c3(1).comment_entity_class = 34;
c3(1).comment_entity_uuid = randomTestClass.generateRandomUUID;
c3(1).comment_contact_uuid = randomTestClass.generateRandomUUID;
c3(1).comment_value = 'comment value: comment 2';

c3(2) = getdb(DB, 'comments', 0);  % Get the template structure for upload
c3(2).comment_entity_class = 34;
c3(2).comment_entity_uuid = randomTestClass.generateRandomUUID;
c3(2).comment_contact_uuid = randomTestClass.generateRandomUUID;
c3(2).comment_value = 'comment value: comment 3';

putdb(DB, 'comments', c3);
DB.commit();


function testContacts_putdb(tStruct) %#ok<DEFNU>
fprintf('\nUnit test putdb function with contacts:\n');
fprintf('It should save a contact\n');
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

fprintf('It should save multiple contacts\n');

c3(1) = getdb(DB, 'contacts', 0);  % Get the template structure for upload
c3(1).contact_first_name = 'Contact';
c3(1).contact_last_name = 'Two';
c3(1).contact_middle_initial = 'Z';
c3(1).contact_address_line_1 = '8524 Dummy Address 1';
c3(1).contact_address_line_2 = '1234 Dummy Address 2';
c3(1).contact_city ='Miami';
c3(1).contact_state = 'Florida';
c3(1).contact_country = 'United States';
c3(1).contact_postal_code = '42486';
c3(1).contact_telephone = '124-157-4574';
c3(1).contact_email = 'c2@email.com';

c3(2) = getdb(DB, 'contacts', 0);  % Get the template structure for upload
c3(2).contact_first_name = 'Contact';
c3(2).contact_last_name = 'Three';
c3(2).contact_middle_initial = 'Z';
c3(2).contact_address_line_1 = '8524 Dummy Address 1';
c3(2).contact_address_line_2 = '1234 Dummy Address 2';
c3(2).contact_city ='Miami';
c3(2).contact_state = 'Florida';
c3(2).contact_country = 'United States';
c3(2).contact_postal_code = '42486';
c3(2).contact_telephone = '124-157-4574';
c3(2).contact_email = 'c3@email.com';

putdb(DB, 'contacts', c3);
DB.commit();

function testDataDefs_putdb(tStruct) %#ok<DEFNU>
fprintf('\nUnit test putdb function with data defs:\n');
fprintf('It should save a data def\n');
DB = tStruct.DB;
d1 = getdb(DB, 'data_defs', 0);
d1.data_def_format = 55;
d1.data_def_sampling_rate = 256;
d1.data_def_description = 'data def description: data def 1';
putdb(DB, 'data_defs', d1);

fprintf('It should save multiple data defs\n');
DB = tStruct.DB;
d3(1) = getdb(DB, 'data_defs', 0);
d3(1).data_def_format = 55;
d3(1).data_def_sampling_rate = 256;
d3(1).data_def_description = 'data def description: data def 2';

d3(2) = getdb(DB, 'data_defs', 0);
d3(2).data_def_format = 55;
d3(2).data_def_sampling_rate = 256;
d3(2).data_def_description = 'data def description: data def 3';

putdb(DB, 'data_defs', d3);
DB.commit();

function testDataMaps_putdb(tStruct) %#ok<DEFNU>
fprintf('\nUnit test putdb function with data maps:\n');
fprintf('It should save a data map\n');
DB = tStruct.DB;
d1 = getdb(DB, 'data_maps', 0);
d1.data_map_def_uuid = randomTestClass.generateRandomUUID;
d1.data_map_entity_uuid = randomTestClass.generateRandomUUID;
d1.data_map_structure_uuid = randomTestClass.generateRandomUUID;
putdb(DB, 'data_maps', d1);

fprintf('It should save multiple data maps\n');
DB = tStruct.DB;
d3(1) = getdb(DB, 'data_maps', 0);
d3(1).data_map_def_uuid = randomTestClass.generateRandomUUID;
d3(1).data_map_entity_uuid = randomTestClass.generateRandomUUID;
d3(1).data_map_structure_uuid = randomTestClass.generateRandomUUID;

d3(2) = getdb(DB, 'data_maps', 0);
d3(2).data_map_def_uuid = randomTestClass.generateRandomUUID;
d3(2).data_map_entity_uuid = randomTestClass.generateRandomUUID;
d3(2).data_map_structure_uuid = randomTestClass.generateRandomUUID;

putdb(DB, 'data_maps', d3);
DB.commit();

function testElements_putdb(tStruct) %#ok<DEFNU>
fprintf('\nUnit test putdb function with elements:\n');
fprintf('It should save an element\n');
DB = tStruct.DB;
e1 = getdb(DB, 'elements', 0);
e1.element_label = 'element label: element 1';
e1.element_parent_uuid = randomTestClass.generateRandomUUID;
e1.element_position = 1;
e1.element_description = 'element description: element 1';
putdb(DB, 'elements', e1);

fprintf('It should save multiple elements\n');
DB = tStruct.DB;
e3(1) = getdb(DB, 'elements', 0);
e3(1).element_label = 'element label: element 2';
e3(1).element_parent_uuid = randomTestClass.generateRandomUUID;
e3(1).element_position = 1;
e3(1).element_description = 'element description: element 2';

e3(2) = getdb(DB, 'elements', 0);
e3(2).element_label = 'element label: element 3';
e3(2).element_parent_uuid = randomTestClass.generateRandomUUID;
e3(2).element_position = 1;
e3(2).element_description = 'element description: element 3';

putdb(DB, 'elements', e3);
DB.commit();

function testEvents_putdb(tStruct) %#ok<DEFNU>
fprintf('\nUnit test putdb function with events:\n');
fprintf('It should save an event\n');
DB = tStruct.DB;
e1 = getdb(DB, 'events', 0);
e1.event_entity_uuid = randomTestClass.generateRandomUUID;
e1.event_type_uuid = randomTestClass.generateRandomUUID;
e1.event_start_time = 200;
e1.event_end_time = 200;
e1.event_position = 1;
e1.event_certainty = 1;
putdb(DB, 'events', e1);

fprintf('It should save multiple events\n');
DB = tStruct.DB;
e3(1) = getdb(DB, 'events', 0);
e3(1).event_entity_uuid = randomTestClass.generateRandomUUID;
e3(1).event_type_uuid = randomTestClass.generateRandomUUID;
e3(1).event_start_time = 200;
e3(1).event_end_time = 200;
e3(1).event_position = 2;
e3(1).event_certainty = 1;

e3(2) = getdb(DB, 'events', 0);
e3(2).event_entity_uuid = randomTestClass.generateRandomUUID;
e3(2).event_type_uuid = randomTestClass.generateRandomUUID;
e3(2).event_start_time = 200;
e3(2).event_end_time = 200;
e3(2).event_position = 3;
e3(2).event_certainty = 1;
putdb(DB, 'events', e3);
DB.commit();

function testEventTypes_putdb(tStruct) %#ok<DEFNU>
fprintf('\nUnit test putdb function with event types:\n');
fprintf('It should save an event type\n');
DB = tStruct.DB;
e1 = getdb(DB, 'event_types', 0);
e1.event_type = 'event type: event type 1';
e1.event_type_description = 'event type description: event type 1';
putdb(DB, 'event_types', e1);


fprintf('It should save multiple events\n');
DB = tStruct.DB;
e3(1) = getdb(DB, 'event_types', 0);
e3(1).event_type = 'event type: event type 2';
e3(1).event_type_description = 'event type description: event type 2';

e3(2) = getdb(DB, 'event_types', 0);
e3(2).event_type = 'event type: event type 3';
e3(2).event_type_description = 'event type description: event type 3';

putdb(DB, 'event_types', e3);
DB.commit();

function testModalities_putdb(tStruct) %#ok<DEFNU>
fprintf('\nUnit test putdb function with modalities:\n');
fprintf('It should save a modality\n');
DB = tStruct.DB;
m1 = getdb(DB, 'modalities', 0);
m1.modality_name = 'modality name: modality 1';
m1.modality_platform = 'modality platform: modality 1';
m1.modality_description = 'modality description: modality 1';
putdb(DB, 'modalities', m1);

fprintf('It should save multiple modalities\n');
DB = tStruct.DB;
m3(1) = getdb(DB, 'modalities', 0);
m3(1).modality_name = 'modality name: modality 2';
m3(1).modality_platform = 'modality platform: modality 2';
m3(1).modality_description = 'modality description: modality 2';

m3(2) = getdb(DB, 'modalities', 0);
m3(2).modality_name = 'modality name: modality 3';
m3(2).modality_platform = 'modality platform: modality 3';
m3(2).modality_description = 'modality description: modality 3';

putdb(DB, 'modalities', m3);
DB.commit();

function testStructures_putdb(tStruct) %#ok<DEFNU>
fprintf('\nUnit test putdb function with structure:\n');
fprintf('It should save a structure\n');
DB = tStruct.DB;
s1 = getdb(DB, 'structures', 0);
s1.structure_name = 'structure name: structure 1';
s1.structure_handler = 'structure handler: structure 1';
s1.structure_parent_uuid = randomTestClass.generateRandomUUID;
putdb(DB, 'structures', s1);

fprintf('It should save multiple structures\n');
DB = tStruct.DB;
s3(1) = getdb(DB, 'structures', 0);
s3(1).structure_name = 'structure name: structure 2';
s3(1).structure_handler = 'structure handler: structure 2';
s3(1).structure_parent_uuid = randomTestClass.generateRandomUUID;

s3(2) = getdb(DB, 'structures', 0);
s3(2).structure_name = 'structure name: structure 3';
s3(2).structure_handler = 'structure handler: structure 3';
s3(2).structure_parent_uuid = randomTestClass.generateRandomUUID;

putdb(DB, 'structures', s3);
DB.commit();

function testTags_putdb(tStruct) %#ok<DEFNU>
fprintf('\nUnit test putdb function with tags:\n');
fprintf('It should save a tag\n');
DB = tStruct.DB;
t1 = getdb(DB, 'tags', 0);  % Get the template structure for upload
t1.tag_name = 'test tag';
t1.tag_entity_uuid = randomTestClass.generateRandomUUID;
t1.tag_entity_class = 45;
putdb(DB, 'tags', t1);

fprintf('It should save multiple tags\n');
DB = tStruct.DB;
t3(1) = getdb(DB, 'tags', 0);  % Get the template structure for upload
t3(1).tag_name = 'test tag';
t3(1).tag_entity_uuid = randomTestClass.generateRandomUUID;
t3(1).tag_entity_class = 45;

t3(2) = getdb(DB, 'tags', 0);  % Get the template structure for upload
t3(2).tag_name = 'test tag';
t3(2).tag_entity_uuid = randomTestClass.generateRandomUUID;
t3(2).tag_entity_class = 45;

putdb(DB, 'tags', t3);
DB.commit();

function testTransforms_putdb(tStruct) %#ok<DEFNU>
fprintf('\nUnit test putdb function with transforms:\n');
fprintf('It should save a transform\n');
DB = tStruct.DB;

t1 = getdb(DB, 'transforms', 0);
t1.transform_uuid = randomTestClass.generateRandomUUID;
t1.transform_string = 'transform string: transform 1';
t1.transform_description = 'transform description: transform 1';
DB.commit();

fprintf('It should save multiple transforms\n');
t3(1) = getdb(DB, 'transforms', 0);
t3(1).transform_uuid = randomTestClass.generateRandomUUID;
t3(1).transform_string = 'transform string: transform 2';
t3(1).transform_description = 'transform description: transform 2';

t3(2) = getdb(DB, 'transforms', 0);
t3(2).transform_uuid = randomTestClass.generateRandomUUID;
t3(2).transform_string = 'transform string: transform 3';
t3(2).transform_description = 'transform description: transform 3';

putdb(DB, 'transforms', t3);
DB.commit();

function testInvalidColumns_putDB(tStruct) %#ok<DEFNU>
fprintf('\nUnit test putdb function with invalid columns:\n');
fprintf('It should throw an exception saving an attribute with an invalid column\n');
DB = tStruct.DB;
a1 = getdb(DB, 'attributes', 0);
a1.attribute_entity_uuid = randomTestClass.generateRandomUUID;
a1.attribute_organizational_uuid = randomTestClass.generateRandomUUID;
a1.attribute_structure_uuid = randomTestClass.generateRandomUUID;
a1.attribute_numeric_value = 1;
a1.attribute_value = 'test attribute value';
a1.invalid_column = 'my extra column';
assertExceptionThrown(...
    @() error(putdb(DB, 'attributes', a1)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving a comment with an invalid column\n');
c1 = getdb(DB, 'comments', 0);  % Get the template structure for upload
c1.comment_entity_class = 34;
c1.comment_entity_uuid = randomTestClass.generateRandomUUID;
c1.comment_contact_uuid = randomTestClass.generateRandomUUID;
c1.comment_value = 'test value';
c1.invalid_column = 'my extra column';
assertExceptionThrown(...
    @() error(putdb(DB, 'comments', c1)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving a contact with an invalid column\n');
c2 = getdb(DB, 'contacts', 0);  % Get the template structure for upload
c2.contact_first_name = 'John';
c2.contact_last_name = 'Doe';
c2.contact_middle_initial = 'Z';
c2.contact_address_line_1 = '8524 Dummy Address 1';
c2.contact_address_line_2 = '1234 Dummy Address 2';
c2.contact_city ='Miami';
c2.contact_state = 'Florida';
c2.contact_country = 'United States';
c2.contact_postal_code = '42486';
c2.contact_telephone = '124-157-4574';
c2.contact_email = 'jdoe@email.com';
c2.invalid_column = 'my extra column';
assertExceptionThrown(...
    @() error(putdb(DB, 'contacts', c2)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving a data def with an invalid column\n');
d1 = getdb(DB, 'data_defs', 0);
d1.data_def_format = 55;
d1.data_def_sampling_rate = 256;
d1.data_def_description = 'data def description';
d1.invalid_column = 'my extra column';
assertExceptionThrown(...
    @() error(putdb(DB, 'data_defs', d1)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving a data map with an invalid column\n');
d2 = getdb(DB, 'data_maps', 0);
d2.data_map_entity_uuid = randomTestClass.generateRandomUUID;
d2.data_map_structure_uuid = randomTestClass.generateRandomUUID;
d2.invalid_column = 'my extra column';
assertExceptionThrown(...
    @() error(putdb(DB, 'data_maps', d2)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving a dataset with an invalid column\n');
d3 = getdb(DB, 'datasets', 0);
d3.dataset_namespace = 'test';
d3.dataset_name = 'test dataset';
d3.dataset_contact_uuid = randomTestClass.generateRandomUUID;
d3.dataset_description = 'test description';
d3.dataset_parent_uuid = randomTestClass.generateRandomUUID;
d3.dataset_modality_uuid = randomTestClass.generateRandomUUID;
d3.invalid_column = 'my extra column';
assertExceptionThrown(...
    @() error(putdb(DB, 'datasets', d3)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving an element with an invalid column\n');
e1 = getdb(DB, 'elements', 0);
e1.element_label = 'test label';
e1.element_parent_uuid = randomTestClass.generateRandomUUID;
e1.element_position = 1;
e1.element_description = 'test description';
e1.invalid_column = 'my extra column';
assertExceptionThrown(...
    @() error(putdb(DB, 'elements', e1)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving an event with an invalid column\n');
e2 = getdb(DB, 'events', 0);
e2.event_entity_uuid = randomTestClass.generateRandomUUID;
e2.event_type_uuid = randomTestClass.generateRandomUUID;
e2.event_start_time = 200;
e2.event_position = 1;
e2.event_end_time = 500;
e2.invalid_column = 'my extra column';
assertExceptionThrown(...
    @() error(putdb(DB, 'events', e2)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving an event type with an invalid column\n');
e3 = getdb(DB, 'event_types', 0);
e3.event_type = 'event type: event type 1';
e3.event_type_description = 'event type description: event type 1';
e3.invalid_column = 'my extra column';
assertExceptionThrown(...
    @() error(putdb(DB, 'events', e3)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving a modality with an invalid column\n');
m1 = getdb(DB, 'modalities', 0);
m1.modality_name = 'modality name: modality 1';
m1.modality_platform = 'modality platform: modality 1';
m1.modality_description = 'modality description: modality 1';
m1.invalid_column = 'my extra column';
assertExceptionThrown(...
    @() error(putdb(DB, 'events', m1)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving a structure with an invalid column\n');
s1 = getdb(DB, 'structures', 0);
s1.structure_name = 'structure name: structure 1';
s1.structure_handler = 'structure handler: structure 1';
s1.structure_parent_uuid = randomTestClass.generateRandomUUID;
s1.invalid_column = 'my extra column';
assertExceptionThrown(...
    @() error(putdb(DB, 'events', s1)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving a tag with an invalid column\n');
t1 = getdb(DB, 'tags', 0);  % Get the template structure for upload
t1.tag_entity_uuid = randomTestClass.generateRandomUUID;
t1.tag_entity_class = 45;
t1.invalid_column = 'my extra column';
assertExceptionThrown(...
    @() error(putdb(DB, 'events', t1)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving a transform with an invalid column\n');
t2 = getdb(DB, 'transforms', 0);
t2.transform_uuid = randomTestClass.generateRandomUUID;
t2.transform_string = 'transform string: transform 1';
t2.transform_description = 'transform description: transform 1';
t2.invalid_column = 'my extra column';
assertExceptionThrown(...
    @() error(putdb(DB, 'events', t2)), ...
    'MATLAB:Java:GenericException');

function testInvalidValues_putDB(tStruct) %#ok<DEFNU>
fprintf('\nUnit test putdb function with invalid values:\n');
fprintf('It should throw an exception saving an attribute with an invalid value: attribute_numeric_value\n');
DB = tStruct.DB;
a1 = getdb(DB, 'attributes', 0);
a1.attribute_entity_uuid = randomTestClass.generateRandomUUID;
a1.attribute_organizational_uuid = randomTestClass.generateRandomUUID;
a1.attribute_structure_uuid = randomTestClass.generateRandomUUID;
a1.attribute_numeric_value = 'invalid value';
a1.attribute_value = 'test attribute value';
assertExceptionThrown(...
    @() error(putdb(DB, 'attributes', a1)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving a comment with an invalid value: entity_class\n');
c1 = getdb(DB, 'comments', 0);  % Get the template structure for upload
c1.comment_entity_class = 'datasets';
c1.comment_entity_uuid = 'hello';
c1.comment_contact_uuid = randomTestClass.generateRandomUUID;
c1.comment_value = 'test value';
assertExceptionThrown(...
    @() error(putdb(DB, 'comments', c1)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving a data def with an invalid value: data_def_sampling_rate\n');
d1 = getdb(DB, 'data_defs', 0);
d1.data_def_format = 'external';
d1.data_def_sampling_rate = 'hello';
d1.data_def_description = 'data def description';
assertExceptionThrown(...
    @() error(putdb(DB, 'data_defs', d1)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving a data map with an invalid value: data_map_structure_uuid\n');
d2 = getdb(DB, 'data_maps', 0);
d2.data_map_entity_uuid = randomTestClass.generateRandomUUID;
d2.data_map_structure_uuid = 'invalid value';
assertExceptionThrown(...
    @() error(putdb(DB, 'data_maps', d2)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving a dataset with an invalid value: dataset_contact_uuid\n');
d3 = getdb(DB, 'datasets', 0);
d3.dataset_namespace = 'test';
d3.dataset_name = 'test dataset';
d3.dataset_contact_uuid = 5;
d3.dataset_description = 'test description';
d3.dataset_parent_uuid = randomTestClass.generateRandomUUID;
d3.dataset_modality_uuid = randomTestClass.generateRandomUUID;
assertExceptionThrown(...
    @() error(putdb(DB, 'datasets', d3)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving an element with an invalid value: element_label\n');
e1 = getdb(DB, 'elements', 0);
e1.element_label = 8;
e1.element_parent_uuid = 'hello';
e1.element_position = 1;
e1.element_description = 'test description';
assertExceptionThrown(...
    @() error(putdb(DB, 'elements', e1)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving an event with an invalid value: event_entity_uuid\n');
e2 = getdb(DB, 'events', 0);
e2.event_entity_uuid = 'invalid value';
e2.event_type_uuid = randomTestClass.generateRandomUUID;
e2.event_start_time = 200;
e2.event_end_time = 200;
e2.event_position = 1;
e2.event_certainty = 1;
assertExceptionThrown(...
    @() error(putdb(DB, 'events', e2)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving a structure with an invalid value: structure_handler\n');
s1 = getdb(DB, 'structures', 0);
s1.structure_name = 'structure name: structure 1';
s1.structure_handler = 'hello';
s1.structure_parent_uuid = 'hello';
assertExceptionThrown(...
    @() error(putdb(DB, 'structures', s1)), ...
    'MATLAB:Java:GenericException');

fprintf('It should throw an exception saving a tag with an invalid value: tag_entity_class\n');
t1 = getdb(DB, 'tags', 0);  % Get the template structure for upload
t1.tag_entity_uuid = randomTestClass.generateRandomUUID;
t1.tag_entity_class = 'invalid value';
assertExceptionThrown(...
    @() error(putdb(DB, 'tags', t1)), ...
    'MATLAB:Java:GenericException');