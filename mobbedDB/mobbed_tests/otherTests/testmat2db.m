function test_suite = testmat2db  %#ok<STOUT>
initTestSuite;

% Function executed before each test
function tStruct = setup %#ok<DEFNU>

% Structure that holds Mobbed connection object constructor arguments
tStruct = struct('name', 'testdb', 'url', 'localhost', ...
    'user', 'postgres', 'password', 'admin', 'DB', []);

% Create connection object (create database first if doesn't exist)
try
    DB = Mobbed(tStruct.name, tStruct.url, tStruct.user, tStruct.password);
catch ME %#ok<NASGU>
    Mobbed.createdb(tStruct.name, tStruct.url, tStruct.user, ...
        tStruct.password, 'mobbed.sql');
    DB = Mobbed(tStruct.name, tStruct.url, tStruct.user, tStruct.password);
end
tStruct.DB = DB;

% Function executed after each test
function teardown(tStruct) %#ok<DEFNU>
try
    tStruct.DB.commit();
    tStruct.DB.close();
catch ME %#ok<NASGU>
end

function testmat2dbOnlyData(tStruct) %#ok<DEFNU>
% Unit test for EEG modality saved as a file
fprintf('\nUnit test mat2db when EEG dataset structure only has a data field:\n');
DB = tStruct.DB;
load eeglab_data_ch.mat;             % load a previously saved EEG structure
s = db2mat(DB);
s.dataset_name = 'eeglabDataOnly';
s.data = EEG;                        % set data to be stored
sUUID = mat2db(DB, s);
dataset = db2mat(DB, sUUID);
assertTrue(~isempty(dataset));

function testmat2NoData(tStruct) %#ok<DEFNU>
% Unit test for EEG modality saved as a file
fprintf('\nUnit test mat2db when EEG dataset structure has no data present:\n');
DB = tStruct.DB;
s = db2mat(DB);                      % get empty structure to fill in
s.dataset_name = 'eeglabNoData';      % dataset name is required
sUUID = mat2db(DB, s);
dataset = db2mat(DB, sUUID);
assertTrue(isempty(dataset.data));

function testmat2NoDefaults(tStruct) %#ok<DEFNU>
% Unit test for EEG modality saved as a file
fprintf('\nUnit test mat2db when EEG dataset structure using no default fields:\n');
DB = tStruct.DB;
m.modality_name = 'SIMPLE';
m = getdb(DB, 'modalities', 1, m);
s = db2mat(DB);                      % get empty structure to fill in
s.dataset_name = 'eeglabNoDefaults';      % dataset name is required
s.dataset_contact_uuid = randomTestClass.generateRandomUUID;
s.dataset_modality_uuid = m.modality_uuid;
s.dataset_namespace = 'test modality';
s.dataset_parent_uuid = randomTestClass.generateRandomUUID;
sUUID = mat2db(DB, s);
db2mat(DB, sUUID);

function testmat2dbEmptyStructure(tStruct) %#ok<DEFNU>
% Unit test for EEG modality saved as a file
fprintf(['\nUnit test mat2db when a empty dataset structure is' ...
'retrieved to fill in prior to the call:\n']);
DB = tStruct.DB;
load eeglab_data_ch.mat;             % load a previously saved EEG structure
s = db2mat(DB);                      % get empty structure to fill in
s.dataset_name = 'eeglabEmptyStructure';      % dataset name is required
s.data = EEG;                        % set data to be stored
sUUID = mat2db(DB, s);
db2mat(DB, sUUID);

function testmat2dbNoEmptyStructure(tStruct) %#ok<DEFNU>
% Unit test for EEG modality saved as a file
fprintf(['\nUnit test mat2db when no empty dataset structure is' ...
'retrieved to fill in prior to the call:\n']);
DB = tStruct.DB;
load eeglab_data_ch.mat;             % load a previously saved EEG structure
s = db2mat(DB);
s.dataset_name = 'eeglabNoEmptyStructure';      % dataset name is required
s.data = EEG;                        % set data to be stored
sUUID = mat2db(DB, s);
db2mat(DB, sUUID);
