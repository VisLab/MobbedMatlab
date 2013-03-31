% MobbedDB Package
% Version 1.0a Beta 1-Feb-2013
%
% Requires PostgreSQL to be installed.
%
% Top-level Mobbed methods
%   data2db          - create a new data definition and store data in database
%   db2data	         - retrieve a data definition from the database
%   db2mat           - retrieve a dataset from the database 
%   extractdb	     - retrieve inter-related items such as events
%   getdb            - retrieve rows from a single table
%   mat2db           - eegBrowse GUI for selecting files for visualization
%   putdb	         - create or update rows from a single table
%
%
% Utility Mobbed methods
%   close	         - close the database descriptor 
%   commit	         - commit the current database transaction, if uncommitted
%   rollback	     - back out of the current transaction if any is uncommitted
%   setAutocommit	 - determines whether the database automatically commits each transaction
%
% Kay A. Robbins, Jeremy Cockfield, and Arif Hoissan
% Copyright 2011-2013 The University of Texas at San Antonio



