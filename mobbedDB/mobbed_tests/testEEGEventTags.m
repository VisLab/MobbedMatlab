function test_suite = testEegEventTags  %#ok<STOUT>
initTestSuite;

% Function executed before each test
function tStruct = setup %#ok<DEFNU>

% Structure that holds Mobbed connection object constructor arguments
tStruct = struct('name', 'testdb', 'url', 'localhost', ...
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

function testEventTagsSummarytags(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for EEG modality dataset that has summary tags' ...
    ' associated with its events\n']);
DB = tStruct.DB;
load eeglab_data_summary_tags1.mat;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
[~,eUUID] = mat2db(DB, s1, 'IsUnique', false);
totalTags = 3;
s2 = getdb(DB, 'tag_entities', 0);
s2.tag_entity_uuid = eUUID;
fprintf(['--It should return the same number of summary tags inserted' ...
    ' in the database\n']);
dbtagCount = length(getdb(DB, 'tag_entities', inf, s2));
assertTrue(isequal(totalTags, dbtagCount));

function testEventTagsMultipleFieldMaps(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for EEG modality dataset that has summary tags' ...
    ' in multiple fieldMaps associated with its events\n']);
DB = tStruct.DB;
load eeglab_data_summary_tags2.mat;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
[~,eUUID] = mat2db(DB, s1, 'IsUnique', false);
totalTags = 5;
s2 = getdb(DB, 'tag_entities', 0);
s2.tag_entity_uuid = eUUID;
fprintf(['--It should return the same number of summary tags inserted' ...
    ' in the database\n']);
dbtagCount = length(getdb(DB, 'tag_entities', inf, s2));
assertTrue(isequal(totalTags, dbtagCount));

function testEventTagsSummaryNoTypeTags(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for EEG modality dataset that has summary tags' ...
    '  that are not event types\n']);
DB = tStruct.DB;
load eeglab_data_summary_tags3.mat;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
[~,eUUID] = mat2db(DB, s1, 'IsUnique', false);
totalTags = 0;
s2 = getdb(DB, 'tag_entities', 0);
s2.tag_entity_uuid = eUUID;
fprintf(['--It should return the same number of summary tags inserted' ...
    ' in the database\n']);
dbtagCount = length(getdb(DB, 'tag_entities', inf, s2));
assertTrue(isequal(totalTags, dbtagCount));

function testEventTagsHedtags(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for EEG modality dataset that has hedtags' ...
    ' associated with its events\n']);
DB = tStruct.DB;
load eeglab_data_individual_tags1.mat;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
UUID = mat2db(DB, s1, 'IsUnique', false);
totalTags = sum(strcmpi('square', {EEG.event.type}) * 2);
s2 = getdb(DB, 'events', 0);
s2.event_dataset_uuid = UUID{1};
s2 = getdb(DB, 'events', inf, s2);
s3 = getdb(DB, 'tag_entities', 0);
s3.tag_entity_uuid = {s2.event_uuid};
fprintf(['--It should return the same number of hedtags inserted' ...
    ' in the database\n']);
dbtagCount = length(getdb(DB, 'tag_entities', inf, s3));
assertTrue(isequal(totalTags, dbtagCount));
% 
function testEventTagsUsertags(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for EEG modality dataset that have usertags' ...
    ' associated with its events\n']);
DB = tStruct.DB;
load eeglab_data_individual_tags2.mat;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
UUID = mat2db(DB, s1, 'IsUnique', false);
totalTags = sum(strcmpi('square', {EEG.event.type}) * 2);
s2 = getdb(DB, 'events', 0);
s2.event_dataset_uuid = UUID{1};
s2 = getdb(DB, 'events', inf, s2);
s3 = getdb(DB, 'tag_entities', 0);
s3.tag_entity_uuid = {s2.event_uuid};
fprintf(['--It should return the same number of usertags inserted' ...
    ' in the database\n']);
dbtagCount = length(getdb(DB, 'tag_entities', inf, s3));
assertTrue(isequal(totalTags, dbtagCount));

function testEventTagsHedtagsUserTags(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for EEG modality dataset that have hedtags and' ...
    ' usertags associated with its events\n']);
DB = tStruct.DB;
load eeglab_data_individual_tags3.mat;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
UUID = mat2db(DB, s1, 'IsUnique', false);
totalTags = sum(strcmpi('square', {EEG.event.type}) * 3);
s2 = getdb(DB, 'events', 0);
s2.event_dataset_uuid = UUID{1};
s2 = getdb(DB, 'events', inf, s2);
s3 = getdb(DB, 'tag_entities', 0);
s3.tag_entity_uuid = {s2.event_uuid};
fprintf(['--It should return the same number of hedtags and usertags' ...
    'inserted in the database\n']);
dbtagCount = length(getdb(DB, 'tag_entities', inf, s3));
assertTrue(isequal(totalTags, dbtagCount));


function testEventTagsBothtags(tStruct) %#ok<DEFNU>
fprintf(['\nUnit test for EEG modality dataset that have summary tags' ...
    'and usertags associated with its events\n']);
DB = tStruct.DB;
load eeglab_data_both_tags1.mat;
s1 = db2mat(DB);
s1.dataset_name = randomClass.generateUUID();
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
[UUID,eUUID] = mat2db(DB, s1, 'IsUnique', false);
summarytags = 3;
s2 = getdb(DB, 'tag_entities', 0);
s2.tag_entity_uuid = eUUID;
dbsummarytagcount = length(getdb(DB, 'tag_entities', inf, s2));
individualtags = sum(strcmpi('square', {EEG.event.type}) * 3);
s3 = getdb(DB, 'events', 0);
s3.event_dataset_uuid = UUID{1};
s3 = getdb(DB, 'events', inf, s3);
s4 = getdb(DB, 'tag_entities', 0);
s4.tag_entity_uuid = {s3.event_uuid};
dbindividualtagcount = length(getdb(DB, 'tag_entities', inf, s4));
dbtagCount = dbsummarytagcount + dbindividualtagcount;
fprintf(['--It should return the same number of summary and user tags' ...
    'inserted in the database\n']);
totaltags = summarytags + individualtags;
assertTrue(isequal(totaltags, dbtagCount));