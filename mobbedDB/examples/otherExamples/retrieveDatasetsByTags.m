% This script will show the different ways to retrieve datasets by tag(s) 

%% Create mobbed object
name = 'mobbed';
hostname = 'localhost';
user = 'postgres';
password = 'admin';
DB = Mobbed(name, hostname, user, password);

%% Store a dataset with tags 
EEG = pop_loadset('filename', 'eeglab_data.set');
s = getdb(DB, 'datasets', 0);
s.dataset_name = 'data1';
s.data = EEG;
sUUID = mat2db(DB, s, false, false, 'Tags', ...
    {'EyeTrack', 'Oddball', 'AudioLeft'});

%% Retrieval by tags not using regular expressions 
dataset1 = DB.getdb('datasets', inf, 'Tag', 'EyeTrack');

%% Retrieval by tags using regular expressions 
dataset2 = DB.getdb('datasets', inf, 'RegExp', 'on', 'Tag', 'Eye*');

%% Retrieval by tags using AND operator 
dataset3 = DB.getdb('datasets', inf, 'Tag', {'EyeTrack','Oddball','AudioLeft'});

%% Retrieval by tags using OR operator  
dataset4 = DB.getdb('datasets', inf, 'Tag', {{'EyeTrack'}, {'Oddball'}});

%% Retrieval by tags using AND and OR operator  
dataset5 = DB.getdb('datasets', inf, 'Tag', {{'EyeTrack'},{'Oddball', ...
    'AudioLeft'}});