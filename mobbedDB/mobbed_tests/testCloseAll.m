function test_suite = testCloseAll %#ok<STOUT>
initTestSuite;

% Function executed before each tests
function tStruct = setup %#ok<DEFNU>

% Structure that holds Mobbed connection object constructor arguments
tStruct = struct('name', 'closedb', 'url', 'localhost', ...
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

function testMultipleConnections(tStruct) %#ok<DEFNU>
DB1 = Mobbed(tStruct.name, tStruct.url, tStruct.user, ...
    tStruct.password, false); %#ok<NASGU>
DB2 = Mobbed(tStruct.name, tStruct.url, tStruct.user, ...
    tStruct.password, false); %#ok<NASGU>
DB3 = Mobbed(tStruct.name, tStruct.url, tStruct.user, ...
    tStruct.password, false); %#ok<NASGU>
clear;
Mobbed.closeAll();
Mobbed.deletedb('closedb', 'localhost', 'postgres', ...
    'admin', false);