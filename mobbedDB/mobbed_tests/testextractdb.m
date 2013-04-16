function test_suite = testextractdb %#ok<STOUT>
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

% Create event types
e1 = getdb(DB, 'event_types', 0);
e1.event_type = 'event type 1';
e1.event_type_description = 'event type description: event type 1';
uuid1 = putdb(DB, 'event_types', e1);

e2 = getdb(DB, 'event_types', 0);
e2.event_type = 'event type 2';
e2.event_type_description = 'event type description: event type 2';
uuid2 = putdb(DB, 'event_types', e2);

e3 = getdb(DB, 'event_types', 0);
e3.event_type = 'event type 3';
e3.event_type_description = 'event type description: event type 3';
uuid3 = putdb(DB, 'event_types', e3);

e4 = getdb(DB, 'event_types', 0);
e4.event_type = 'event type 4';
e4.event_type_description = 'event type description: event type 4';
uuid4 = putdb(DB, 'event_types', e4);

datasetUuid = randomTestClass.generateRandomUUID;

% Create events
e1 = getdb(DB, 'events', 0);
e1.event_entity_uuid = datasetUuid;
e1.event_type_uuid = uuid1{1};
e1.event_start_time = 1;
e1.event_end_time = 1;
e1.event_position = 1;
e1.event_certainty = 1;
putdb(DB, 'events', e1);

e2 = getdb(DB, 'events', 0);
e2.event_entity_uuid = datasetUuid;
e2.event_type_uuid = uuid2{1};
e2.event_start_time = 2;
e2.event_end_time = 2;
e2.event_position = 2;
e2.event_certainty = 1;
putdb(DB, 'events', e2);

e3 = getdb(DB, 'events', 0);
e3.event_entity_uuid = datasetUuid;
e3.event_type_uuid = uuid3{1};
e3.event_start_time = 3;
e3.event_end_time = 3;
e3.event_position = 3;
e3.event_certainty = 1;
putdb(DB, 'events', e3);

e4 = getdb(DB, 'events', 0);
e4.event_entity_uuid = randomTestClass.generateRandomUUID;
e4.event_type_uuid = uuid4{1};
e4.event_start_time = 1;
e4.event_end_time = 1;
e4.event_position = 1;
e4.event_certainty = 1;
putdb(DB, 'events', e4);

tStruct.DB.commit();
tStruct.event_type_uuids = [uuid1(:),uuid2(:),uuid3(:),uuid4(:)];

function teardown(tStruct) %#ok<DEFNU>
tStruct.DB.close();

function testextractdbRange(tStruct) %#ok<DEFNU>
fprintf('\nUnit test extractdb function with Range:\n');

fprintf('\nIt should extract all events within default range ([0,1]) with no search qulifications and no limit \n');
DB = tStruct.DB;
[mStructure, extStructure] = extractdb(DB, 'events', [], 'events', [], inf);
assertTrue(~isempty(mStructure));
assertTrue(~isempty(extStructure));

fprintf('\nIt should extract all events within default range ([0,1]) with no search qualifications and a limit\n');
DB = tStruct.DB;
limit = 1;
[mStructure, extStructure] = extractdb(DB, 'events', [], 'events', [], limit);
assertTrue(~isempty(mStructure));
assertTrue(~isempty(extStructure));
assertTrue(isequal(length(mStructure), limit));
assertTrue(isequal(length(extStructure), limit));

fprintf('\nIt should extract all events within default range ([0,1]) with search qualifications from inStructure and no limit\n');
DB = tStruct.DB;
% only look for interrelated events in type 1 events
inStructure.event_type_uuid = tStruct.event_type_uuids{1};
[mStructure, extStructure] = extractdb(DB, 'events', inStructure, 'events', [], inf);
assertTrue(~isempty(mStructure));
assertTrue(~isempty(extStructure));

fprintf('\nIt should extract all events within default range ([0,1]) with search qualifications from inStructure and a limit\n');
DB = tStruct.DB;
limit = 1;
% only look for interrelated events in type 1 events
inStructure.event_type_uuid = tStruct.event_type_uuids{1};
[mStructure, extStructure] = extractdb(DB, 'events', inStructure, 'events', [], limit);
assertTrue(~isempty(mStructure));
assertTrue(~isempty(extStructure));
assertTrue(isequal(length(mStructure), limit));
assertTrue(isequal(length(extStructure), limit));

fprintf('\nIt should extract all events within default range ([0,1]) with search qualifications from outStructure and no limit\n');
DB = tStruct.DB;
% only look for type 2 events in all events
outStructure.event_type_uuid = tStruct.event_type_uuids{2};
[mStructure, extStructure] = extractdb(DB, 'events', [], 'events', outStructure, inf);
assertTrue(~isempty(mStructure));
assertTrue(~isempty(extStructure));

fprintf('\nIt should extract all events within default range ([0,1]) with search qualifications from outStructure and a limit\n');
DB = tStruct.DB;
limit = 1;
% only look for type 2 events in all events
outStructure.event_type_uuid = tStruct.event_type_uuids{2};
[mStructure, extStructure] = extractdb(DB, 'events', [], 'events', outStructure, limit);
assertTrue(~isempty(mStructure));
assertTrue(~isempty(extStructure));
assertTrue(isequal(length(mStructure), limit));
assertTrue(isequal(length(extStructure), limit));

fprintf('\nIt should extract all events within default range ([0,1]) with search qualifications from inStructure and outStructure and no limit\n');
DB = tStruct.DB;
% only look for type 2 events in type 1 events
inStructure.event_type_uuid = tStruct.event_type_uuids{1};
outStructure.event_type_uuid = tStruct.event_type_uuids{2};
[mStructure, extStructure] = extractdb(DB, 'events', inStructure, 'events', outStructure, inf);
assertTrue(~isempty(mStructure));
assertTrue(~isempty(extStructure));

fprintf('\nIt should extract all events within default range ([0,1]) with search qualifications from inStructure and outStructure and a limit\n');
DB = tStruct.DB;
limit = 1;
% only look for type 2 events in type 1 events
inStructure.event_type_uuid = tStruct.event_type_uuids{1};
outStructure.event_type_uuid = tStruct.event_type_uuids{2};
[mStructure, extStructure] = extractdb(DB, 'events', inStructure, 'events', outStructure, inf);
assertTrue(~isempty(mStructure));
assertTrue(~isempty(extStructure));
assertTrue(isequal(length(mStructure), limit));
assertTrue(isequal(length(extStructure), limit));

fprintf('\nIt should extract no events from an event belonging in a different dataset\n');
DB = tStruct.DB;
inStructure.event_type_uuid = tStruct.event_type_uuids{4};
[mStructure, extStructure] = extractdb(DB, 'events', inStructure, 'events', [], inf);
assertTrue(isempty(mStructure));
assertTrue(isempty(extStructure));