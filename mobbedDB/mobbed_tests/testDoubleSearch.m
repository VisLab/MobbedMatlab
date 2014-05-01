function test_suite = testDoubleSearch %#ok<STOUT>
initTestSuite;

% Function executed before each tests
function tStruct = setup %#ok<DEFNU>

% Structure that holds Mobbed connection object constructor arguments
tStruct = struct('name', 'testdb', 'url', 'localhost', ...
    'user', 'postgres', 'password', 'admin', 'DB', []);

% Create connection object (create database first if doesn't exist)
try
    DB = Mobbed(tStruct.name, tStruct.url, tStruct.user, ...
        tStruct.password, true);
catch ME %#ok<NASGU>
    Mobbed.createdb(tStruct.name, tStruct.url, tStruct.user, ...
        tStruct.password, 'mobbed.sql', false);
    DB = Mobbed(tStruct.name, tStruct.url, tStruct.user, ...
        tStruct.password, true);
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
d.dataset_name = randomClass.generateUUID();
d.dataset_description = 'reference dataset description ';
d.dataset_uuid = putdb(DB, 'datasets', d);
datasetUuid = d.dataset_uuid{1};

% light flash event
e1 = getdb(DB, 'events', 0);
e1.event_dataset_uuid = datasetUuid;
e1.event_type_uuid = eventTypeUuid1{1};
e1.event_start_time = 1;
e1.event_end_time = 1;
e1.event_position = 1;
e1.event_certainty = 1;
putdb(DB, 'events', e1);

% button press event
e2 = getdb(DB, 'events', 0);
e2.event_dataset_uuid = datasetUuid;
e2.event_type_uuid = eventTypeUuid3{1};
e2.event_start_time = 2;
e2.event_end_time = 2;
e2.event_position = 2;
e2.event_certainty = 1;
putdb(DB, 'events', e2);

% vibration event
e3 = getdb(DB, 'events', 0);
e3.event_dataset_uuid = datasetUuid;
e3.event_type_uuid = eventTypeUuid2{1};
e3.event_start_time = 3;
e3.event_end_time = 3;
e3.event_position = 3;
e3.event_certainty = 1;
putdb(DB, 'events', e3);

tStruct.datasetUuid = datasetUuid;
tStruct.event_type_uuids = [eventTypeUuid1(:), eventTypeUuid2(:), ...
    eventTypeUuid3(:)];

% Function executed after each test
function teardown(~) %#ok<DEFNU>
try
    Mobbed.closeall();
catch ME %#ok<NASGU>
end

function testSearch(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with double search:\n');
fprintf(['It should extract events that have a start time of' ...
    ' 1,2 or 3 seconds\n']);
DB = tStruct.DB;
s = getdb(DB, 'events', 0);  
s.event_dataset_uuid = tStruct.datasetUuid;
s.event_start_time = [1, 2, 3]; 
sNew = getdb(DB, 'events', inf, s); 
fprintf(['--It should return a structure array containing three' ...
    ' events with a start time of 1,2, or 3 seconds\n']);
assertEqual(length(sNew), 3);

fprintf(['It should extract events that have a start and end' ...
    ' time of 1 or 2 seconds\n']);
DB = tStruct.DB;
s = getdb(DB, 'events', 0);  
s.event_dataset_uuid = tStruct.datasetUuid;
s.event_start_time = [1, 2]; 
s.event_end_time = [1, 2];
sNew = getdb(DB, 'events', inf, s); 
fprintf(['--It should return a structure array containing two' ...
    ' events with a start and end time of 1 or 2 seconds\n']);
assertEqual(length(sNew), 2);

fprintf(['It should extract events that have a start time' ...
    ' within a second of 1,2 or 3 seconds\n']);
s = getdb(DB, 'events', 0); 
s.event_dataset_uuid = tStruct.datasetUuid;
s.event_start_time.values = [1, 2, 3]; 
s.event_start_time.range = [-1, 1]; 
sNew = getdb(DB, 'events', inf, s); 
fprintf(['--It should return a structure array containing three events' ...
    ' that have a start time within a second of 1,2, or 3 seconds\n']);
assertEqual(length(sNew), 3);

fprintf(['It should extract events that have a start and end' ...
    ' time within a second of 1,2 or 3 seconds\n']);
s = getdb(DB, 'events', 0); 
s.event_dataset_uuid = tStruct.datasetUuid;
s.event_start_time.values = [1, 2, 3]; 
s.event_start_time.range = [-1, 1]; 
s.event_end_time = [1, 2, 3]; 
sNew = getdb(DB, 'events', inf, s); 
fprintf(['--It should return a structure array containing three events' ...
    ' with start and end time within a second of 1,2, or 3 seconds\n']);
assertEqual(length(sNew), 3);