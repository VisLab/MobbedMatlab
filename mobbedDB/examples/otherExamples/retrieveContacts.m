% This script will retrieve contacts from the database using different
% arguments

%% Create MobbedDB object
name = 'mobbed';
hostname = 'localhost';
user = 'postgres';
password = 'admin';
DB = Mobbed(name, hostname, user, password);

%% Retrieve contact John Doe using regular expressions 
contact1.contact_first_name = 'John';
contact1.contact_last_name = 'D*';
contact1 = DB.getdb('contacts', inf, contact1, 'RegExp', 'on');

%% Retrieve contact John Doe not using regular expressions  
contact2.contact_first_name = 'John';
contact2.contact_last_name = 'Doe';
contact2 = DB.getdb('contacts', inf, contact2);

%% Retrieve multiple contacts using cellstrs 
contact3.contact_first_name = {'John', 'Test'};
contact3.contact_last_name = {'Doe', 'User'};
contact3 = DB.getdb('contacts', inf, contact3);

%% Retrieve all contacts in the database  
contact4 = DB.getdb('contacts', inf);