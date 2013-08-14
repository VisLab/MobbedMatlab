% Mobbed Package
% Version 1.0a Beta 20-May-2013 09:36:35
%
% Requires PostgreSQL to be installed.
%
% Mobbed top-level methods
%   data2db            - create a data definition and store corresponding
%                        data in database
%   db2data	           - retrieve a data definition and associated data
%                        from the database
%   db2mat             - retrieve a dataset from the database
%   getconnection      - returns a database connection 
%   getdb              - retrieve rows from a single table
%   mat2db             - create and store a dataset in the database
%   putdb	           - create or update rows from a single table
%
% Mobbed utility methods
%   close	           - close the database descriptor
%
% Mobbed static methods
%   closeall           - closes all workspace database descriptors
%   createcred         - create a database credentials file
%   createdb           - create a database using username and password
%   createdbc          - create a database using the credentials from a
%                        property file
%   deletedb           - delete a database using username and password
%   deletedbc          - delete a database using the credentials from a
%                        property file
%   getcred            - get an open database connection using the
%                        credentials from a property file
%
% Kay A. Robbins and Jeremy Cockfield
% Copyright 2011-2013 The University of Texas at San Antonio



