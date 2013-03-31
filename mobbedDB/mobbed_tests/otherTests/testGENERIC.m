function test_suite = testGENERIC %#ok<STOUT>
initTestSuite;

function tStruct = setup %#ok<DEFNU>
tStruct = struct('name', 'testdb', 'url', 'localhost', ...
                 'user', 'postgres', 'password', 'admin', 'DB', []);
try
   DB = Mobbed(tStruct.name, tStruct.url, tStruct.user, tStruct.password);
catch ME %#ok<NASGU>
   Mobbed.createdb(tStruct.name, tStruct.url, tStruct.user, ...
                   tStruct.password, 'mobbed.sql');
   DB = Mobbed(tStruct.name, tStruct.url, tStruct.user, tStruct.password);
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
    tStruct.DB.commit();
    tStruct.DB.close();
catch ME %#ok<NASGU>
end

function testGeneric_File(tStruct) %#ok<DEFNU>
% Unit test for GENERIC modality and mat2db
fprintf('\nUnit test generic modality saved as a file:\n');

% Create Mobbed connection object
DB = tStruct.DB;

fprintf('It should save a generic dataset with only elements and no extras\n');
testData = genericTestClass(5, 0, 0, 0, 0);
assertTrue(isvalid(testData));
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'GENERIC - 5 elements, no extras stored as file';
s1.data = testData.data;
s1.dataset_modality_uuid = tStruct.mUUID;
sUUID = mat2db(DB, s1, false);  

fprintf('It should retrieve an generic dataset from a file with only elements\n');
s2 = db2mat(DB, sUUID);
assertTrue(~isempty(s2(1).data));
assertTrue(isequal(s1(1).data, s2(1).data));

fprintf('It should save a generic dataset with elements and extras\n');
testData = genericTestClass(5, 0, 0, 0, 3);
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'GENERIC - 5 elements, 3 extras stored as file';
s1.data = testData.data;
s1.dataset_modality_uuid = tStruct.mUUID;
sUUID = mat2db(DB, s1, false);  

fprintf('It should retrieve an generic dataset from a file with elements and extras\n');
s2 = db2mat(DB, sUUID);
assertTrue(~isempty(s2(1).data));
assertTrue(isequal(s1(1).data, s2(1).data));

fprintf('It should save a generic dataset with elements, events and extras\n');
testData = genericTestClass(5, 4, 0, 0, 3);
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'GENERIC - 5 elements, 4 events and 3 extras stored as file';
s1.data = testData.data;
s1.dataset_modality_uuid = tStruct.mUUID;
sUUID = mat2db(DB, s1, false);  

fprintf('It should retrieve an generic dataset from a file with only elements\n');
s2 = db2mat(DB, sUUID);
assertTrue(isstruct(s2(1).data));
assertTrue(~isempty(s2(1).data));
assertTrue(isequal(s1(1).data, s2(1).data));

fprintf('It should save a generic dataset with elements, events, numeric stream feature, and extras as a file\n');
testData = genericTestClass(5, 4, 'numeric_stream', 3, 3);
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'GENERIC - 5 elements, 4 events, numeric stream, and 3 extras stored in tables';
s1.data = testData.data;
s1.dataset_modality_uuid = tStruct.mUUID;
sUUID = mat2db(DB, s1, false); 

s2 = db2mat(DB, sUUID);
assertTrue(~isempty(s2(1).data));
assertTrue(isequal(s1(1).data, s2(1).data));

fprintf('It should save a generic dataset with elements, events, numeric data feature, and extras as a file\n');
testData = genericTestClass(5, 4, 'numeric', 3, 3);
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'GENERIC - 5 elements, 4 events, numeric stream, and 3 extras stored in tables';
s1.data = testData.data;
s1.dataset_modality_uuid = tStruct.mUUID;
sUUID = mat2db(DB, s1, false); 

s2 = db2mat(DB, sUUID);
assertTrue(~isempty(s2(1).data));
assertTrue(isequal(s1(1).data, s2(1).data));

fprintf('It should save a generic dataset with elements, events, xml features, and extras as a file\n');
testData = genericTestClass(5, 4, 'xml', 0, 3);
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'GENERIC - 5 elements, 4 events, xml, and 3 extras stored in tables';
s1.data = testData.data;
s1.dataset_modality_uuid = tStruct.mUUID;
sUUID = mat2db(DB, s1, false);  

fprintf('It should retreive a generic dataset with elements, events, xml features, and extras\n');
s2 = db2mat(DB, sUUID);
assertTrue(~isempty(s2(1).data));
assertTrue(isequal(s1(1).data, s2(1).data));

fprintf('It should save a GENERIC dataset with existing events in a file\n');
allEventTypesLength = length(getdb(DB, 'event_types', inf));
mStructure.event_type_entity_uuid = sUUID{1};
allEventTypeMapsLength = length(getdb(DB, 'event_type_maps', inf));
eventTypes = getdb(DB, 'event_type_maps', inf, mStructure);
eventTypes = {eventTypes.event_type_uuid};
eventTypesLength = length(eventTypes);
testData = genericTestClass(5, 4, 'xml', 0, 3);
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'GENERIC - stored as file with existing events';
s1.data = testData.data;
s1.dataset_modality_uuid = tStruct.mUUID;
mat2db(DB, s1, false, 'eventTypes', eventTypes);
allEventTypesLength2 = length(getdb(DB, 'event_types', inf));
allEventTypeMapsLength2 = length(getdb(DB, 'event_type_maps', inf));
assertTrue(isequal(allEventTypesLength, allEventTypesLength2));
assertTrue(isequal(allEventTypeMapsLength + eventTypesLength, allEventTypeMapsLength2 )); 

fprintf('It should save a GENERIC dataset with new events in a file\n');
allEventTypesLength = length(getdb(DB, 'event_types', inf));
allEventTypeMapsLength = length(getdb(DB, 'event_type_maps', inf));
testData = genericTestClass(5, 4, 'xml', 0, 3);
s2 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s2.dataset_name = 'GENERIC - stored as file with new events';
s2.data = testData.data;
s2.dataset_modality_uuid = tStruct.mUUID;
sUUID = mat2db(DB, s2, false);
uniqueEventTypesLength = length(unique({s2.data.event.type}));
allEventTypesLength2 = length(getdb(DB, 'event_types', inf));
allEventTypeMapsLength2 = length(getdb(DB, 'event_type_maps', inf));
assertTrue(isequal(allEventTypesLength + uniqueEventTypesLength, allEventTypesLength2)); 
assertTrue(isequal(allEventTypeMapsLength + uniqueEventTypesLength, allEventTypeMapsLength2 )); 

fprintf('It should save a GENERIC dataset with existing events with opposite case in a file\n');
allEventTypesLength = length(getdb(DB, 'event_types', inf));
mStructure.event_type_entity_uuid = sUUID{1};
allEventTypeMapsLength = length(getdb(DB, 'event_type_maps', inf));
eventTypes = getdb(DB, 'event_type_maps', inf, mStructure);
eventTypes = {eventTypes.event_type_uuid};
eventTypesLength = length(eventTypes);
testData = genericTestClass(5, 4, 'xml', 0, 3);
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'GENERIC - stored as file with existing events with opposite case';
s1.data = testData.data;
lowerCaseEvents = arrayfun(@(x) lower(x.type), s1.data.event, 'UniformOutput', false); 
[s1.data.event.type] = lowerCaseEvents{:};
s1.dataset_modality_uuid = tStruct.mUUID;
mat2db(DB, s1, false, 'eventTypes', eventTypes);
allEventTypesLength2 = length(getdb(DB, 'event_types', inf));
allEventTypeMapsLength2 = length(getdb(DB, 'event_type_maps', inf));
assertTrue(isequal(allEventTypesLength, allEventTypesLength2));
assertTrue(isequal(allEventTypeMapsLength + eventTypesLength, allEventTypeMapsLength2 )); 

fprintf('It should save a Generic dataset that returns unique events with new events as a file\n');
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'Generic - return unique events';
testData = genericTestClass(5, 4, 'xml', 0, 3);
s1.data = testData.data;
s1.dataset_modality_uuid = tStruct.mUUID;
[sUUID, uniqueEvents] = mat2db(DB, s1, false);
uniqueEvents2 = unique({s1.data.event.type});
assertTrue(iscellstr(sUUID));
assertTrue(isequal(length(uniqueEvents), length(uniqueEvents2)));

fprintf('It should save an EEG dataset that returns unique events with existing events as a file\n');
s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
s1.dataset_name = 'Generic - return unique events';
testData = genericTestClass(5, 4, 'xml', 0, 3);
s1.data = testData.data;
s1.dataset_modality_uuid = tStruct.mUUID;
[sUUID, uniqueEvents] = mat2db(DB, s1, false, 'eventTypes', uniqueEvents);
uniqueEvents2 = unique({s1.data.event.type});
assertTrue(iscellstr(sUUID));
assertTrue(isequal(length(uniqueEvents), length(uniqueEvents2)));

fprintf('It should save a strucuture array of Generic datasets that returns unique events with the same events as a file\n');
testData = genericTestClass(5, 4, 'xml', 0, 3);
s1(1).dataset_name = 'Generic - dataset 1';
s1(1).dataset_modality_uuid = tStruct.mUUID;
s1(1).data = testData.data;
s1(2).dataset_name = 'Generic - dataset 2';
s1(2).dataset_modality_uuid = tStruct.mUUID;
s1(2).data = testData.data;
[sUUID, uniqueEvents] = mat2db(DB, s1, false);
assertTrue(iscellstr(sUUID));
assertTrue(isequal(length(uniqueEvents), length(uniqueEvents2)));

fprintf('It should save a strucuture array of Generic datasets that returns unique events with different events as a file\n');
s1(2).data.event(1).type = 'new unique event type';
[sUUID, uniqueEvents] = mat2db(DB, s1, false);
uniqueEvents2 = union(unique({s1(1).data.event.type}), unique({s1(2).data.event.type}));
assertTrue(iscellstr(sUUID));
assertTrue(isequal(length(uniqueEvents), length(uniqueEvents2)));
