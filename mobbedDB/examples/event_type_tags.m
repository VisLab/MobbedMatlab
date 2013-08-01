%% Setup for this installation.
dbName = 'dbmobbed';
dbHost = 'localhost';
dbPort = 5432;
dbUser = 'postgres';
dbPassword = 'admin';
%
% %% 4.1 Create a database
% Mobbed.createdb(dbName, [dbHost ':' num2str(dbPort)], dbUser, ...
%                 dbPassword, 'mobbed.sql');
%
%% 4.2 Accessing the database in MATLAB
DB = Mobbed(dbName, [dbHost ':' num2str(dbPort)], dbUser, dbPassword);

%% 4.3 Upload datasets to the database (no optional parameters)
s = db2mat(DB);                      % get empty structure
s.dataset_name = 'eeglab_data2';      % dataset name is required
s.data = EEG;                        % set data to be stored
sUUID = mat2db(DB, s);               %#ok<NASGU> % store in database DB