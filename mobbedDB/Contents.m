% MobbedDB Package
% Version 1.0a Beta 1-Feb-2013
%
% Requires PostgreSQL to be installed.
%
% Mobbed top-level methods
%   data2db            - create a data definition and store corresponding
%                        data in database
%   db2data	           - retrieve a data definition and associated data
%                        from the database
%   db2mat             - retrieve a dataset from the database
%   extractdb	       - retrieve inter-related items such as events from
%                        more complex scenarios
%   getdb              - retrieve rows from a single table
%   mat2db             - create and store a dataset in the database
%   putdb	           - create or update rows from a single table
%
%
% Mobbed utility methods
%   close	           - close the database descriptor
%   commit	           - commit the current database transaction, if
%                        uncommitted
%   rollback	       - rollback the current transaction if any is
%                        uncommitted
%   setAutocommit	   - Set or clear flag indicating whether to
%                        automatically commit transactions
%
% Mobbed static methods
%   createCredentials  - create a credentials file
%   createdb           - create a database using username and password
%   createdbc          - create a database using a credentials file
%   deletedb           - delete a database using username and password
%   deletedbc          - delete a database using a credentials file
%   getFromCredentials - get an open database connection given credentials
%
% Kay A. Robbins and Jeremy Cockfield
% Copyright 2011-2013 The University of Texas at San Antonio



