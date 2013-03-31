% This script will create a database

%% (create database)

%Mobbed.createdb(dbName, hostAddress, userName, password, tableDefXml)
Mobbed.createdb('mobbed','localhost', 'postgres', 'admin', 'mobbed.xml', false);
