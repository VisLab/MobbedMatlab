function test_suite = testEEGEventTags  %#ok<STOUT>
initTestSuite;

% Function executed before each test
function tStruct = setup %#ok<DEFNU>

% Structure that holds Mobbed connection object constructor arguments
tStruct = struct('name', 'test_event_tags_db', 'url', 'localhost', ...
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
tStruct.DB = DB;

% Get EEG modality uuid
m = getdb(DB, 'modalities', inf);
mNames = {m.modality_name};
pos = strcmp('EEG', mNames);
uuids = {m.modality_uuid};
tStruct.mUUID = uuids{pos};

% Function executed after each test
function teardown(~) %#ok<DEFNU>
try
    Mobbed.closeall();
catch ME %#ok<NASGU>
end

function testEventTags(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for EEG modality dataset that has tags' ...
    ' associated with its events:\n']);
fprintf(['It should store a EEG modality dataset that has tags' ...
    ' associated with its events:\n']);
DB = tStruct.DB;
load eeglab_data_individual_tags.mat;
s1 = db2mat(DB);
s1.dataset_name = 'EEG event tags';
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
mat2db(DB, s1, 'IsUnique', false);
twoTags = sum(strcmp('square', {EEG.event.type}));
oneTag = sum(strcmp('rt', {EEG.event.type}));
totalTags = twoTags * 2 + oneTag;
dbtagCount = length(getdb(DB, 'tags', inf));
assertTrue(totalTags, dbtagCount);