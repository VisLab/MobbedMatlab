function test_suite = testExtractdb %#ok<STOUT>
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
e1.event_type = 'light flash';
e1.event_type_description = 'event type description: event type 1';
eventTypeUuid1 = putdb(DB, 'event_types', e1);

e2 = getdb(DB, 'event_types', 0);
e2.event_type = 'vibration';
e2.event_type_description = 'event type description: event type 2';
eventTypeUuid2 = putdb(DB, 'event_types', e2);

e3 = getdb(DB, 'event_types', 0);
e3.event_type = 'button press';
e3.event_type_description = 'event type description: event type 3';
eventTypeUuid3 = putdb(DB, 'event_types', e3);

d = getdb(DB, 'datasets', 0);
d.dataset_name = randomClass.generateString();
d.dataset_description = 'reference dataset description ';
d.dataset_uuid = putdb(DB, 'datasets', d);
datasetUuid = d.dataset_uuid{1};

% light flash event
e1 = getdb(DB, 'events', 0);
e1.event_dataset_uuid = datasetUuid;
e1.event_type_uuid = eventTypeUuid1{1};
e1.event_start_time = 3;
e1.event_end_time = 3;
e1.event_position = 1;
e1.event_certainty = 1;
putdb(DB, 'events', e1);

% button press event
e2 = getdb(DB, 'events', 0);
e2.event_dataset_uuid = datasetUuid;
e2.event_type_uuid = eventTypeUuid3{1};
e2.event_start_time = 4;
e2.event_end_time = 4;
e2.event_position = 2;
e2.event_certainty = 1;
putdb(DB, 'events', e2);

% vibration event
e3 = getdb(DB, 'events', 0);
e3.event_dataset_uuid = datasetUuid;
e3.event_type_uuid = eventTypeUuid2{1};
e3.event_start_time = 7;
e3.event_end_time = 7;
e3.event_position = 3;
e3.event_certainty = 1;
putdb(DB, 'events', e3);

e4 = getdb(DB, 'events', 0);
e4.event_dataset_uuid = datasetUuid;
e4.event_type_uuid = eventTypeUuid3{1};
e4.event_start_time = 9;
e4.event_end_time = 9;
e4.event_position = 4;
e4.event_certainty = 1;
putdb(DB, 'events', e4);

tStruct.datasetUuid = datasetUuid;
tStruct.event_type_uuids = [eventTypeUuid1(:), eventTypeUuid2(:), ...
    eventTypeUuid3(:)];

function teardown(tStruct) %#ok<DEFNU>
% Function executed after each test
try
    tStruct.DB.close();
catch ME %#ok<NASGU>
end

function testInS(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for extractdb with inS structure search criteria:\n');

fprintf(['It should extract events that have other events that occur' ...
    ' within the default range (1 second) of their occurance\n']);
DB = tStruct.DB;
inS.event_dataset_uuid = tStruct.datasetUuid;
[mStructure, extStructure] = extractdb(DB, 'events', inS, 'events', [], ...
    inf);
fprintf(['--It should return a structure array containing one event' ...
    ' that found other events in the default range\n']);
assertEqual(length(mStructure), 1);
fprintf(['--It should return a structure array containing one' ...
    ' unique event found in the default range\n']);
assertEqual(length(extStructure), 1);

fprintf(['It should extract events that have other events that occur' ...
    ' within 2 seconds of their occurance\n']);
[mStructure, extStructure] = extractdb(DB, 'events', inS, 'events', [], ...
    inf, 'Range', [0,2]);
fprintf(['--It should return a structure array containing two events' ...
    ' that found other events in the range of 2 seconds\n']);
assertEqual(length(mStructure), 2);
fprintf(['--It should return a structure array containing two' ...
    ' unique events found in the range of 2 seconds\n']);
assertEqual(length(extStructure), 2);

fprintf(['It should extract at most one event that has other events' ... 
    ' that occur within 2 seconds of its occurance\n']);
[mStructure, extStructure] = extractdb(DB, 'events', inS, 'events', [], ...
    1, 'Range', [0,2]);
fprintf(['--It should return a structure array containing one event' ...
    ' that found other events in the range of 2 seconds\n']);
assertEqual(length(mStructure), 1);
fprintf(['--It should return a structure array containing one' ...
    ' unique event found in the range of 2 seconds\n']);
assertEqual(length(extStructure), 1);

fprintf(['It should extract light flash events that have other events' ... 
    ' that occur within 2 seconds of their occurance\n']);
inS.event_type_uuid = tStruct.event_type_uuids{1};
[mStructure, extStructure] = extractdb(DB, 'events', inS, 'events', [], ...
    Inf, 'Range', [0,2]);
fprintf(['--It should return a structure array containing one light' ...
    ' flash event that found other events in the range of 2 seconds\n']);
assertEqual(length(mStructure), 1);
fprintf(['--It should return a structure array containing one' ...
    ' unique event found in the range of 2 seconds\n']);
assertEqual(length(extStructure), 1);