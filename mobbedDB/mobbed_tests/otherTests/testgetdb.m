function test_suite = testgetdb %#ok<STOUT>
initTestSuite;

function tStruct = setup %#ok<DEFNU>
tStruct = struct('name', 'testdb', 'url', 'localhost', ...
                 'user', 'postgres', 'password', 'admin', 'DB', []);
try
   DB = Mobbed(tStruct.name, tStruct.url, tStruct.user, tStruct.password);
catch ME %#ok<NASGU>
   Mobbed.createdb(tStruct.name, tStruct.url, tStruct.user, ...
                   tStruct.password, 'mobbed.sql', false);
   DB = Mobbed(tStruct.name, tStruct.url, tStruct.user, tStruct.password);
end
tStruct.DB = DB;

m = getdb(DB, 'modalities', inf);
mNames = {m.modality_name};
pos = strcmp('EEG', mNames);
uuids = {m.modality_uuid};
tStruct.mUUID = uuids{pos};

function teardown(tStruct) %#ok<DEFNU>
% Function executed after each test
try
    tStruct.DB.commit();
    tStruct.DB.close();
catch ME %#ok<NASGU>
end

function testTags_getdb(tStruct) %#ok<DEFNU>
fprintf('\nUnit test getdb function with tags:\n');
fprintf('It should retrieve a dataset with a single tag\n');
DB = tStruct.DB;
assertTrue(isvalid(DB));
load('EEG.mat');
assertTrue(isstruct(EEG)); 
assertTrue(~isempty(EEG));
d1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
d1.dataset_name = 'Dataset with single tag';
d1.data = EEG;
d1.dataset_modality_uuid = tStruct.mUUID;
sNew1 = mat2db(DB, d1, false, 'Tags', 'single tag');
assertTrue(iscellstr(sNew1));
sNew2 = getdb(DB, 'datasets', inf, 'Tags', {{'single tag'}});
assertTrue(isstruct(sNew2));
assertTrue(isequal(sNew2.dataset_name, d1.dataset_name));

fprintf('It should retrieve a dataset with a single tag using wildcards\n');
DB = tStruct.DB;
assertTrue(isvalid(DB));
load('EEG.mat');
assertTrue(isstruct(EEG)); 
assertTrue(~isempty(EEG));
d1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
d1.dataset_name = 'Dataset with single tag - wildcards';
d1.data = EEG;
d1.dataset_modality_uuid = tStruct.mUUID;
sNew1 = mat2db(DB, d1, false, 'Tags', 'singlewildcardtag');
assertTrue(iscellstr(sNew1));
sNew2 = getdb(DB, 'datasets', 1, 'Tags', {{'singlewild*'}}, 'RegExp', 'on');
assertTrue(isstruct(sNew2));
assertTrue(isequal(sNew2.dataset_name, d1.dataset_name));

fprintf('It should retrieve a dataset with multiple tags using wildcards\n');
DB = tStruct.DB;
assertTrue(isvalid(DB));
load('EEG.mat');
assertTrue(isstruct(EEG)); 
assertTrue(~isempty(EEG));
d1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
d1.dataset_name = 'Dataset with multiple tags - wildcards';
d1.data = EEG;
d1.dataset_modality_uuid = tStruct.mUUID;
sNew1 = mat2db(DB, d1, false, 'Tags', {'multiplewildcardtag1', 'multiplewildcardtag2'});
assertTrue(iscellstr(sNew1));
sNew2 = getdb(DB, 'datasets', 1, 'Tags', {{'multiplewildcard*'}}, 'RegExp', 'on');
assertTrue(isstruct(sNew2));
assertTrue(isequal(sNew2.dataset_name, d1.dataset_name));

fprintf('It should retrieve a dataset with multiple tags using and operator\n');
DB = tStruct.DB;
assertTrue(isvalid(DB));
load('EEG.mat');
assertTrue(isstruct(EEG)); 
assertTrue(~isempty(EEG));
d1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
d1.dataset_name = 'Dataset with multiple tags - and operator';
d1.data = EEG;
d1.dataset_modality_uuid = tStruct.mUUID;
sNew1 = mat2db(DB, d1, false, 'Tags', {'multipleandtag1','multipleandtag2'});
assertTrue(iscellstr(sNew1));
sNew2 = getdb(DB, 'datasets', 1, 'Tags', {{'multipleandtag1','multipleandtag2'}});
assertTrue(isstruct(sNew2));
assertTrue(isequal(sNew2.dataset_name, d1.dataset_name));

fprintf('It should retrieve a dataset with multiple tags using or operator\n');
DB = tStruct.DB;
assertTrue(isvalid(DB));
load('EEG.mat');
assertTrue(isstruct(EEG)); 
assertTrue(~isempty(EEG));
d1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
d1.dataset_name = 'Dataset with multiple tags - or operator';
d1.data = EEG;
d1.dataset_modality_uuid = tStruct.mUUID;
sNew1 = mat2db(DB, d1, false, 'Tags', {'multipleortag1','multipleortag2'});
assertTrue(iscellstr(sNew1));
sNew2 = getdb(DB, 'datasets', 1, 'Tags', {{'multipleortag1'},{'multipleortag2'}});
assertTrue(isstruct(sNew2));
assertTrue(isequal(sNew2.dataset_name, d1.dataset_name));

fprintf('It should retrieve a dataset with multiple tags using or operator and and operator\n');
DB = tStruct.DB;
assertTrue(isvalid(DB));
load('EEG.mat');
assertTrue(isstruct(EEG)); 
assertTrue(~isempty(EEG));
d1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
d1.dataset_name = 'Dataset with multiple tags - and operator and or operator';
d1.data = EEG;
d1.dataset_modality_uuid = tStruct.mUUID;
sNew1 = mat2db(DB, d1, false, 'Tags', {'multipleandtag3', 'multipleandtag4','multipleortag3','multipleortag4'});
assertTrue(iscellstr(sNew1));
sNew2 = getdb(DB, 'datasets', 1, 'Tags', {{'multipleandtag3'},{'multipleortag3','multipleortag4'}});
assertTrue(isstruct(sNew2));
assertTrue(isequal(sNew2.dataset_name, d1.dataset_name));

fprintf('It should retrieve a dataset with multiple tags using and operator and wildcards\n');
DB = tStruct.DB;
assertTrue(isvalid(DB));
load('EEG.mat');
assertTrue(isstruct(EEG)); 
assertTrue(~isempty(EEG));
d1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
d1.dataset_name = 'Dataset with multiple tags - and operator and wildcards';
d1.data = EEG;
d1.dataset_modality_uuid = tStruct.mUUID;
sNew1 = mat2db(DB, d1, false, 'Tags', {'multipleandtag5', 'multipleandwildcardtag'});
assertTrue(iscellstr(sNew1));
sNew2 = getdb(DB, 'datasets', 1, 'Tags', {{'multipleandtag5','multipleandwild*'}}, 'RegExp', 'on');
assertTrue(isstruct(sNew2));
assertTrue(isequal(sNew2.dataset_name, d1.dataset_name));

fprintf('It should retrieve a dataset with multiple tags using or operator and wildcards\n');
DB = tStruct.DB;
assertTrue(isvalid(DB));
load('EEG.mat');
assertTrue(isstruct(EEG)); 
assertTrue(~isempty(EEG));
d1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
d1.dataset_name = 'Dataset with multiple tags - or operator and wildcards';
d1.data = EEG;
d1.dataset_modality_uuid = tStruct.mUUID;
sNew1 = mat2db(DB, d1, false, 'Tags', {'multipleortag5', 'multipleorwildcardtag'});
assertTrue(iscellstr(sNew1));
sNew2 = getdb(DB, 'datasets', 1, 'Tags', {{'multipleortag5','multipleorwildcard*'}}, 'RegExp', 'on');
assertTrue(isstruct(sNew2));
assertTrue(isequal(sNew2.dataset_name, d1.dataset_name));

fprintf('It should retrieve a dataset with multiple tags using and operator, or operator, and wildcards\n');
DB = tStruct.DB;
assertTrue(isvalid(DB));
load('EEG.mat');
assertTrue(isstruct(EEG));
assertTrue(~isempty(EEG));
d1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
d1.dataset_name = 'Dataset with multiple tags - and operator, or operator, and wildcards';
d1.data = EEG;
d1.dataset_modality_uuid = tStruct.mUUID;
sNew1 = mat2db(DB, d1, false, 'Tags', {'multipleandtag6','multipleortag6', 'multipleandorwildcardtag'});
assertTrue(iscellstr(sNew1));
sNew2 = getdb(DB, 'datasets', 1, 'Tags', {{'multipleandtag6'}, {'multipleortag6','multipleandor*'}}, 'RegExp', 'on');
assertTrue(isstruct(sNew2));
assertTrue(isequal(sNew2.dataset_name, d1.dataset_name));

fprintf('It should retrieve a dataset with multiple tags using regular expressions\n');
DB = tStruct.DB;
assertTrue(isvalid(DB));
load('EEG.mat');
assertTrue(isstruct(EEG));
assertTrue(~isempty(EEG));
d1 = getdb(DB, 'datasets', 0);  % Get the template structure for upload
d1.dataset_name = 'Dataset with multiple tags - regular expression';
d1.data = EEG;
d1.dataset_modality_uuid = tStruct.mUUID;
sNew1 = mat2db(DB, d1, false, 'Tags', {'regexptag1','regexptag2', 'regexptag3'});
assertTrue(iscellstr(sNew1));
sNew2 = getdb(DB, 'datasets', 1, 'Tags', {{'regexptag*'}}, 'RegExp', 'on');
assertTrue(isstruct(sNew2));
assertTrue(isequal(sNew2.dataset_name, d1.dataset_name));
