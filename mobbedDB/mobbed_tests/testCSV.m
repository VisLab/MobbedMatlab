function test_suite = testCSV %#ok<STOUT>
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
pos = strcmp('CSV', mNames);
uuids = {m.modality_uuid};
tStruct.mUUID = uuids{pos};

% Function executed after each test
function teardown(~) %#ok<DEFNU>
try
    Mobbed.closeall();
catch ME %#ok<NASGU>
end

function testNoEventTypeAndEventTags(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for CVS modality dataset with no event type and' ...
    ' event tags\n']);
DB = tStruct.DB;
load csv_data1.mat;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
s1.data = CSV;
s1.dataset_modality_uuid = tStruct.mUUID;
s1.data.etype_spec.header_lines = 1;
s1.data.etype_spec.type_columns = [1,2,3];
s1.data.etype_spec.pathname = which('event_types.csv');
s1.data.event_spec.header_lines = 1;
s1.data.event_spec.type_columns = [1,2,3];
s1.data.event_spec.latency_column = 4;
s1.data.event_spec.certainty_column = 5;
s1.data.event_spec.pathname = which('events.csv');
s1.data.data_spec.pathname = which('data.csv');
UUIDs = mat2db(DB, s1, 'IsUnique', false);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));

function testEventTypeAndEventTags(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for CVS modality dataset with event type and' ...
    ' event tags\n']);
DB = tStruct.DB;
load csv_data1.mat;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
s1.data = CSV;
s1.dataset_modality_uuid = tStruct.mUUID;
s1.data.etype_spec.header_lines = 1;
s1.data.etype_spec.type_columns = [1,2,3];
s1.data.etype_spec.tags_columns = 4;
s1.data.etype_spec.pathname = which('event_types.csv');
s1.data.event_spec.header_lines = 1;
s1.data.event_spec.type_columns = [1,2,3];
s1.data.event_spec.latency_column = 4;
s1.data.event_spec.certainty_column = 5;
s1.data.event_spec.hedtags_column = 6;
s1.data.event_spec.usertags_column = 7;
s1.data.event_spec.pathname = which('events.csv');
s1.data.data_spec.pathname = which('data.csv');
UUIDs = mat2db(DB, s1, 'IsUnique', false);
fprintf('--It should return a cell array containing one string uuid\n');
assertTrue(iscellstr(UUIDs));
assertEqual(1, length(UUIDs));