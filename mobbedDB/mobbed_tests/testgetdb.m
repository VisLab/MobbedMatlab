function test_suite = testgetdb %#ok<STOUT>
initTestSuite;

% Function executed before each tests
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

% Function executed after each test
function teardown(tStruct) %#ok<DEFNU>
try
    tStruct.DB.commit();
    tStruct.DB.close();
catch ME %#ok<NASGU>
end

function testGetdbExactMatchTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with tags that are a exact match\n');
fprintf('It should retrieve a dataset by a tag that is a exact match\n');
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = 'dataset with exact match tag';
mat2db(DB, s1, 'IsUnique', false, 'Tags', 'ExactMatchTag');
s2 = getdb(DB, 'datasets', 1, 'Tags', {{'ExactMatchTag'}});
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s2));
assertEqual(1, length(s2));

function testGetdbRegExpTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with tags that are regular expressions\n');
fprintf(['It should retrieve a dataset by a tag that is a regular' ...
' expression\n']);
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = 'dataset with reg exp tag';
mat2db(DB, s1, 'IsUnique', false, 'Tags', 'RegExpTag');
s2 = getdb(DB, 'datasets', 1, 'Tags', {{'RegExpT*'}}, 'RegExp', 'on');
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s2));
assertEqual(1, length(s2));

function testGetdbORConditionTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with tags using the OR condition\n');
fprintf('It should retrieve a dataset by tags using the OR condition\n');
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = 'dataset with OR condition tags';
mat2db(DB, s1, 'IsUnique', false, 'Tags', {'ORTAG1','ORTAG2'});
s2 = getdb(DB, 'datasets', 1, 'Tags', {{'ORTAG1','ORTAG2'}});
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s2));
assertEqual(1, length(s2));

function testGetdbANDConditionTags(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for getdb with tags using the AND condition\n');
fprintf('It should retrieve a dataset by tags using the AND condition\n');
DB = tStruct.DB;
s1 = db2mat(DB);
s1.dataset_name = 'dataset with AND condition tags';
mat2db(DB, s1, 'IsUnique', false, 'Tags', {'ANDTAG1','ANDTAG2'});
s2 = getdb(DB, 'datasets', 1, 'Tags', {'ANDTAG1', 'ANDTAG2'});
fprintf('--It should return a structure array that contains a dataset\n');
assertTrue(isstruct(s2));
assertEqual(1, length(s2));
% 
% fprintf('\nIt should retrieve a dataset with multiple tags using or operator and and operator\n');
% DB = tStruct.DB;
% assertTrue(isvalid(DB));
% load eeglab_data_ch.mat;
% assertTrue(isstruct(EEG));
% assertTrue(~isempty(EEG));
% s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
% s1.dataset_name = 'Dataset with multiple tags - and operator and or operator';
% s1.data = EEG;
% s1.dataset_modality_uuid = tStruct.mUUID;
% sNew1 = mat2db(DB, s1, 'IsUnique', false, 'Tags', {'multipleandtag3', 'multipleandtag4','multipleortag3','multipleortag4'});
% assertTrue(iscellstr(sNew1));
% sNew2 = getdb(DB, 'datasets', 1, 'Tags', {{'multipleandtag3'},{'multipleortag3','multipleortag4'}});
% assertTrue(isstruct(sNew2));
% assertTrue(isequal(sNew2.dataset_name, s1.dataset_name));
% 
% fprintf('\nIt should retrieve a dataset with multiple tags using and operator and wildcards\n');
% DB = tStruct.DB;
% assertTrue(isvalid(DB));
% load eeglab_data_ch.mat;
% assertTrue(isstruct(EEG));
% assertTrue(~isempty(EEG));
% s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
% s1.dataset_name = 'Dataset with multiple tags - and operator and wildcards';
% s1.data = EEG;
% s1.dataset_modality_uuid = tStruct.mUUID;
% sNew1 = mat2db(DB, s1, 'IsUnique', false, 'Tags', {'multipleandtag5', 'multipleandwildcardtag'});
% assertTrue(iscellstr(sNew1));
% sNew2 = getdb(DB, 'datasets', 1, 'Tags', {{'multipleandtag5','multipleandwild*'}}, 'RegExp', 'on');
% assertTrue(isstruct(sNew2));
% assertTrue(isequal(sNew2.dataset_name, s1.dataset_name));
% 
% fprintf('\nIt should retrieve a dataset with multiple tags using or operator and wildcards\n');
% DB = tStruct.DB;
% assertTrue(isvalid(DB));
% load eeglab_data_ch.mat;
% assertTrue(isstruct(EEG));
% assertTrue(~isempty(EEG));
% s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
% s1.dataset_name = 'Dataset with multiple tags - or operator and wildcards';
% s1.data = EEG;
% s1.dataset_modality_uuid = tStruct.mUUID;
% sNew1 = mat2db(DB, s1, 'IsUnique', false, 'Tags', {'multipleortag5', 'multipleorwildcardtag'});
% assertTrue(iscellstr(sNew1));
% sNew2 = getdb(DB, 'datasets', 1, 'Tags', {{'multipleortag5','multipleorwildcard*'}}, 'RegExp', 'on');
% assertTrue(isstruct(sNew2));
% assertTrue(isequal(sNew2.dataset_name, s1.dataset_name));
% 
% fprintf('\nIt should retrieve a dataset with multiple tags using and operator, or operator, and wildcards\n');
% DB = tStruct.DB;
% assertTrue(isvalid(DB));
% load eeglab_data_ch.mat;
% assertTrue(isstruct(EEG));
% assertTrue(~isempty(EEG));
% s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
% s1.dataset_name = 'Dataset with multiple tags - and operator, or operator, and wildcards';
% s1.data = EEG;
% s1.dataset_modality_uuid = tStruct.mUUID;
% sNew1 = mat2db(DB, s1, 'IsUnique', false, 'Tags', {'multipleandtag6','multipleortag6', 'multipleandorwildcardtag'});
% assertTrue(iscellstr(sNew1));
% sNew2 = getdb(DB, 'datasets', 1, 'Tags', {{'multipleandtag6'}, {'multipleortag6','multipleandor*'}}, 'RegExp', 'on');
% assertTrue(isstruct(sNew2));
% assertTrue(isequal(sNew2.dataset_name, s1.dataset_name));
% 
% fprintf('\nIt should retrieve a dataset with multiple tags using regular expressions\n');
% DB = tStruct.DB;
% assertTrue(isvalid(DB));
% load eeglab_data_ch.mat;
% assertTrue(isstruct(EEG));
% assertTrue(~isempty(EEG));
% s1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
% s1.dataset_name = 'Dataset with multiple tags - regular expression';
% s1.data = EEG;
% s1.dataset_modality_uuid = tStruct.mUUID;
% sNew1 = mat2db(DB, s1, 'IsUnique', false, 'Tags', {'regexptag1','regexptag2', 'regexptag3'});
% assertTrue(iscellstr(sNew1));
% sNew2 = getdb(DB, 'datasets', 1, 'Tags', {{'regexptag*'}}, 'RegExp', 'on');
% assertTrue(isstruct(sNew2));
% assertTrue(isequal(sNew2.dataset_name, s1.dataset_name));
