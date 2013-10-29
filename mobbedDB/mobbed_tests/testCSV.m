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

function testNoEventTypeAndEventTags(tStruct)
fprintf(['\nUnit test for CVS modality dataset with no event type and' ...
    ' event tags:\n']);

event_type_file = which ('events_types_no_tags.csv');
event_file = which('events_no_tags.csv');
data_file = which('data.csv');


