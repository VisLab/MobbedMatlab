% This script will store contacts in the datababse  

%% Create MobbedDB object
name = 'shooter';
hostname = 'localhost';
user = 'postgres';
password = 'admin';
DB = Mobbed(name, hostname, user, password);

%% Store a contact named John Doe
contact1 = getdb(DB, 'contacts', 0); 
contact1.contact_first_name =  'John';
contact1.contact_last_name =  'Doe';
contact1.contact_middle_initial = 'Z';
contact1.contact_address_line_1 = '8524 Dummy Address 1';
contact1.contact_address_line_2 = '1234 Dummy Address 2';
contact1.contact_city =  'DoeVille';
contact1.contact_state = 'Florida';
contact1.contact_country = 'United States';
contact1.contact_postal_code = '42486';
contact1.contact_telephone = '124-157-4574';
contact1.contact_email = 'jdoe@email.com';
contact1 = DB.putdb('contacts', contact1);
commit(DB);

%% Store a contact named Test User 
contact2 = getdb(DB, 'contacts', 0); 
contact2.contact_first_name = 'Test';
contact2.contact_last_name = 'User';
contact2.contact_middle_initial = 'T';
contact2.contact_address_line_1 = '1244 Test Address 1';
contact2.contact_address_line_2 ='1834 Tes Address 2';
contact2.contact_city='Houston';
contact2.contact_state='Texas';
contact2.contact_country = 'United States';
contact2.contact_postal_code= '42486';
contact2.contact_telephone='124-157-4574';
contact2.contact_email = 'tuser@email.com';
contact2 = DB.putdb('contacts', contact2);
commit(DB);

% %% Update city of contact John Doe
% contact3 = getdb(DB, 'contacts', 0); 
% contact3.contact_first_name =  'John';
% contact3.contact_last_name =  'Doe';
% contact3 = getdb(DB, 'contacts', 1, contact3); 
% contact3.contact_city = 'Orlando';
% putdb(DB, 'contacts', contact3);
% commit(DB);

