% Mobbed connection object to a Postgresql database
%
% Usage:
%   >>  DB = Mobbed(dbname, hostname, username, password)
%   >>  DB = Mobbed(dbname, hostname, username, password, verbose)
%
% Description:
% DB = Mobbed(dbname, hostname, username, password) creates a connection
%   object to a Postgresql database called dbname on host hostname using
%   the username user with the specified password. The DB connection
%   object is used to read from and write to the database.
%
% DB = Mobbed(..., verbose) creates a connection object to a Postgresql
%    database. If verbose is false, then informative messages are
%    suppressed. If verbose is true (the default), then various
%    informative messages and timing information is output during
%    execution.
%
% Example 1:
% % Open a connection to an existing database called mobbed on local
% % machine
%    DB = Mobbed('mobbed', 'localhost','postgres', 'admin');
%
% Example 2:
% % Retrieve up to 10 datasets that have been tagged 'Visual' from DB
%    sNew = getdb(DB, 'datasets', 10, 'Tag',{'Visual'});
%
% Example 3:
% % Create
% Notes:
%  - This class has static methods to create a database (createdb) and
%    delete a database (deletedb).
%  - Users can create multiple connections to the same database or
%    connections to different databases.
%
% See also:
%

% Copyright (C) 2012  Kay Robbins, Jeremy Cockfield, UTSA,
% {krobbins,jcockfie}@cs.utsa.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

classdef Mobbed < hgsetget
    properties
        Verbose;
    end % public properties
    
    properties (Access = private)
        DbManager                   % Manager to database
    end % private properties
    
    methods
        
        function DB = Mobbed(dbname, hostname, username, password, ...
                varargin)
            % Create a connection object for database name on hostname
            parser = inputParser();
            parser.addRequired('dbname', @ischar);
            parser.addRequired('hostname', @ischar);
            parser.addRequired('username', @ischar);
            parser.addRequired('password', @ischar);
            parser.addOptional('verbose', true, @islogical);
            parser.parse(dbname, hostname, username, password, ...
                varargin{:});
            DB.Verbose = parser.Results.verbose;
            % Set the properties of a database
            DbHandler.addjavapath();
            DB.DbManager = edu.utsa.mobbed.ManageDB(...
                parser.Results.dbname, parser.Results.hostname, ...
                parser.Results.username, parser.Results.password, ...
                parser.Results.verbose);
        end % Mobbed
        
        function close(DB, varargin)
            % Close the database descriptor or a cursor
            parser = inputParser();
            parser.addParamValue('DataCursor', [], @(x) ischar(x) && ...
                ~isempty(x));
            parser.parse(varargin{:});
            if ~isempty(parser.Results.DataCursor)
                DB.DbManager.closeCursor(parser.Results.DataCursor);
            else
                DB.DbManager.closeConnection();
            end
        end % close
        
        function UUIDs = data2db(DB, datadefs, varargin)
            % Create a data definition and store corresponding data in
            % database
            parser = inputParser();
            parser.addRequired('datadefs', @(x) isstruct(x) && ...
                all(ismember(fieldnames(db2data(DB)), fieldnames(x))));
            parser.addOptional('TimeStamps', [],  @(x) isdouble(x));
            parser.parse(datadefs, varargin{:});
            columns = cell(DB.DbManager.getColumnNames('datadefs'));
            try
                doubleColumns = cell(DB.DbManager.getDoubleColumns(...
                    'datadefs'));
                [values, doubleValues] = ...
                    DbHandler.extractvalues(rmfield(datadefs, ...
                    'data'), doubleColumns, true);
                UUIDs = cell(DB.DbManager.addRows('datadefs', ...
                    columns, values, doubleColumns, doubleValues));
                for a = 1:length(UUIDs)
                    DbHandler.storedatadef(DB, UUIDs{a}, datadefs(a), ...
                        parser.Results.TimeStamps);
                end
            catch ME
                try
                    DB.DbManager.rollback();
                catch ME1
                    ME = addCause(ME, ME1);
                end
                throw(ME);
            end
            DB.DbManager.commitTransaction();
        end % data2db
        
        function ddef = db2data(DB, varargin)
            % Retrieve a data definition and associated data from the
            % database
            parser = inputParser();
            parser.addOptional('UUIDs', {},@(x) isstruct(x) && ...
                all(ismember(cell(DB.DbManager.getColumnNames(...
                'datamaps')), ...
                fieldnames(x))) || DbHandler.validateuuids(x));
            parser.parse(varargin{:});
            columns = cell(DB.DbManager.getColumnNames('datadefs'));
            ddef = cell2struct(cell(length(columns),1), columns,1);
            ddef.data = [];
            if ~isempty(parser.Results.UUIDs)
                if isstruct(parser.Results.UUIDs)
                    UUIDs = {parser.Results.UUIDs.datamap_def_uuid};
                else
                    UUIDs = DbHandler.reformatstring(parser.Results.UUIDs);
                end
                numUUIDs = length(UUIDs);
                ddef = repmat(ddef, 1, numUUIDs);
                for k = 1:numUUIDs
                    values = DbHandler.createjaggedarray(UUIDs{k});
                    outValues = ...
                        cell(DB.DbManager.searchRows('datadefs', ...
                        1, 'off', [], [], [], {'datadef_uuid'}, values, ...
                        [], [], [], []));
                    outColumns = ...
                        cell(DB.DbManager.getColumnNames('datadefs'));
                    tempDatadef = cell2struct(outValues, outColumns, 2)';
                    tempDatadef.data = DbHandler.retrievedatadef(DB, ...
                        UUIDs{k}, tempDatadef.datadef_format, true);
                    ddef(k) = tempDatadef;
                end
            end
        end % db2data
        
        function datasets = db2mat(DB, varargin)
            % Retrieve a dataset from the database
            parser = inputParser();
            parser.addOptional('UUIDs', {}, @DbHandler.validateuuids);
            parser.parse(varargin{:});
            columns = cell(DB.DbManager.getColumnNames('datasets'));
            datasets = cell2struct(cell(length(columns),1), columns,1);
            datasets.data = [];
            if ~isempty(parser.Results.UUIDs)
                UUIDs = DbHandler.reformatstring(parser.Results.UUIDs);
                numUUIDs = length(UUIDs);
                datasets = repmat(datasets, 1, numUUIDs);
                for k = 1:numUUIDs
                    values = DbHandler.createjaggedarray(UUIDs{k});
                    outValues = ...
                        cell(DB.DbManager.searchRows('datasets', ...
                        1, 'off', [], [], [], {'dataset_uuid'}, ...
                        values, [], [], [], []));
                    outColumns = ...
                        cell(DB.DbManager.getColumnNames('datasets'));
                    tempDataset = cell2struct(outValues, outColumns, 2)';
                    tempDataset.data = ...
                        DbHandler.retrievefile(DB, UUIDs{k}, false);
                    datasets(k) = tempDataset;
                end
            end
        end % db2mat
        
        function connection = getconnection(DB)
            % Returns a database connection
            connection = DB.DbManager.getConnection();
        end % getConnection
        
        function outS = getdb(DB, table, limit, varargin)
            % Retrieve rows from a single table
            parser = inputParser();
            parser.addRequired('table', @(x) ischar(x) && ~isempty(x));
            parser.addRequired('limit', @(x) isnumeric(x) && ...
                isscalar(x) && x > -1);
            parser.addOptional('inS', [], @(x) isstruct(x) && isscalar(x));
            parser.addParamValue('Tags', [], @iscell);
            parser.addParamValue('Attributes', {}, @iscell);
            parser.addParamValue('RegExp', 'off', ...
                @(x) any(strcmpi(x, {'on', 'off'})));
            parser.addParamValue('TagMatch', 'exact', ...
                @(x) any(strcmpi(x, {'exact', 'prefix', 'word'})));
            parser.addParamValue('DataCursor', [], @(x) ischar(x) && ...
                ~isempty(x));
            parser.parse(table, limit, varargin{:});
            columns = [];
            values = [];
            doubleColumns = [];
            doubleValues = [];
            range = [];
            outS = [];
            tags = DbHandler.createjaggedarray(parser.Results.Tags);
            attributes = ...
                DbHandler.createjaggedarray(parser.Results.Attributes);
            if parser.Results.limit == 0
                columns = cell(DB.DbManager.getColumnNames(...
                    parser.Results.table));
                outS = cell2struct(cell(length(columns),1), columns,1);
                return;
            end
            if ~isempty(parser.Results.inS)
                allFields = fieldnames(parser.Results.inS);
                structure = rmfield(parser.Results.inS, ...
                    allFields(structfun(@isempty,parser.Results.inS)));
                columns = fieldnames(structure);
                doubleColumns = columns(ismember(columns, ...
                    cell(DB.DbManager.getDoubleColumns(table))));
                columns = columns(~ismember(columns, doubleColumns));
                [values, doubleValues, range] = ...
                    DbHandler.extractvalues(structure, ...
                    doubleColumns, false);
            end
            outValues = ...
                cell(DB.DbManager.searchRows(parser.Results.table, ...
                parser.Results.limit, parser.Results.RegExp, ...
                parser.Results.TagMatch, tags, ...
                attributes, columns, values, ...
                doubleColumns, doubleValues, range, ...
                parser.Results.DataCursor));
            if ~isempty(outValues)
                outColumns = cell(DB.DbManager.getColumnNames(...
                    parser.Results.table));
                outS = cell2struct(outValues, outColumns, 2)';
            end
        end % getdb
        
        function [UUIDs, uniqueEvents] = mat2db(DB, datasets, varargin)
            % Create and store a dataset in the database
            parser = inputParser();
            parser.addRequired('datasets', @(x) isstruct(x) && ...
                all(ismember(fieldnames(db2mat(DB)), fieldnames(x))));
            parser.addParamValue('IsUnique', true, @islogical);
            parser.addParamValue('Tags', {}, @(x) ischar(x) || ...
                iscellstr(x));
            parser.addParamValue('EventTypes', {}, ...
                @DbHandler.validateuuids);
            parser.parse(datasets, varargin{:});
            uniqueEvents = parser.Results.EventTypes;
            numDatasets = length(datasets);
            UUIDs = cell(1, numDatasets);
            modality = 'EEG';
            namespace = 'mobbed';
            columns = cell(DB.DbManager.getColumnNames('datasets'));
            tagMap = DB.DbManager.getTagMap();
            try
                for k = 1:numDatasets
                    % Check the dataset version
                    if ~isempty(datasets(k).dataset_namespace)
                        namespace = datasets(k).dataset_namespace;
                    end
                    datasets(k).dataset_version = ...
                        DB.DbManager.checkDatasetVersion(...
                        parser.Results.IsUnique, namespace, ...
                        datasets(k).dataset_name);
                    % Check the dataset modality
                    if ~isempty(datasets(k).dataset_modality_uuid)
                        [modality, datasets(k).dataset_modality_uuid] = ...
                            DbHandler.checkmodality(DB, ...
                            datasets(k).dataset_modality_uuid);
                    end
                    % Store the dataset
                    doubleColumns = cell(DB.DbManager.getDoubleColumns(...
                        'datasets'));
                    [values, doubleValues] = ...
                        DbHandler.extractvalues(rmfield(datasets(k), ...
                        'data'), doubleColumns, true);
                    datasetUuid = cell(DB.DbManager.addRows('datasets', ...
                        columns, values, doubleColumns, doubleValues));
                    UUIDs{k} = datasetUuid{1};
                    % Store the tag(s)
                    if ~isempty(parser.Results.Tags)
                        tagMap = ...
                            DB.DbManager.storeTags(...
                            DB.DbManager.getConnection(), tagMap, ...
                            'datasets', ...
                            java.util.UUID.fromString(UUIDs{k}), ...
                            parser.Results.Tags);
                    end
                    % Store the actual data
                    if ~isempty(datasets(k).data)
                        uniqueEvents = eval([modality ...
                            '_Modality.store(DB, UUIDs{k},' ...
                            'datasets(k).data, uniqueEvents)']);
                    end
                end
            catch ME
                try
                    DB.DbManager.rollbackTransaction();
                catch ME1
                    ME = addCause(ME, ME1);
                end
                throw(ME);
            end
            DB.DbManager.commitTransaction();
        end % mat2db
        
        function UUIDs = putdb(DB, table, inS)
            % Create or update rows from a single table
            parser = inputParser();
            parser.addRequired('table', @(x) ischar(x) && ~isempty(x));
            parser.addRequired('inS', @(x) isstruct(x) && ...
                all(ismember(cell(DB.DbManager.getColumnNames(table)), ...
                fieldnames(x))));
            parser.parse(table, inS);
            try
                columns = fieldnames(parser.Results.inS);
                doubleColumns = cell(DB.DbManager.getDoubleColumns(...
                    parser.Results.table));
                [values, doubleValues] = ...
                    DbHandler.extractvalues(parser.Results.inS, ...
                    doubleColumns, true);
                UUIDs = cell(DB.DbManager.addRows(table, columns, ...
                    values, doubleColumns, doubleValues));
            catch ME
                try
                    DB.DbManager.rollbackTransaction();
                catch ME1
                    ME = addCause(ME, ME1);
                end
                throw(ME);
            end
            DB.DbManager.commitTransaction();
        end % putdb
        
    end % public methods
    
    methods(Static)
        
        function closeall()
            % Closes all workspace database descriptors
            edu.utsa.mobbed.ManageDB.closeAllConnections();
        end
        
        function configPath = createcred()
            % Create a database credentials file
            configPath = inputdbcreds;
        end % createCredentials
        
        function createdb(dbname, hostname, username, password, script, ...
                varargin)
            % Create a database using username and password
            parser = inputParser();
            parser.addRequired('dbname', @ischar);
            parser.addRequired('hostname', @ischar);
            parser.addRequired('username', @ischar);
            parser.addRequired('password', @ischar);
            parser.addOptional('script', 'mobbed.sql', @ischar);
            parser.addOptional('verbose', true, @islogical);
            parser.parse(dbname, hostname, username, password, script, ...
                varargin{:});
            edu.utsa.mobbed.ManageDB.createDatabase(...
                parser.Results.dbname, parser.Results.hostname, ...
                parser.Results.username, parser.Results.password, ...
                which(parser.Results.script), parser.Results.verbose);
        end % createdb
        
        function createdbc(filename, script)
            % Create a database using the credentials from a property file
            parser = inputParser();
            parser.addRequired('filename', @ischar);
            parser.parse(filename);
            properties = cell(...
                edu.utsa.mobbed.ManageDB.loadCredentials(filename));
            Mobbed.createdb(properties{1}, properties{2}, ...
                properties{3}, properties{4}, script);
        end % createdbc
        
        function deletedb(dbname, hostname, username, password, varargin)
            % Delete a database using username and password
            parser = inputParser();
            parser.addRequired('dbname', @ischar);
            parser.addRequired('hostname', @ischar);
            parser.addRequired('username', @ischar);
            parser.addRequired('password', @ischar);
            parser.addOptional('verbose', true, @islogical);
            parser.parse(dbname, hostname, username, password, ...
                varargin{:});
            edu.utsa.mobbed.ManageDB.dropDatabase(...
                parser.Results.dbname, parser.Results.hostname, ...
                parser.Results.username, parser.Results.password, ...
                parser.Results.verbose);
        end % deletedb
        
        function deletedbc(filename)
            % Delete a database using the credentials from a property file
            parser = inputParser();
            parser.addRequired('filename', @ischar);
            parser.parse(filename);
            properties = cell(...
                edu.utsa.mobbed.ManageDB.loadCredentials(filename));
            Mobbed.deletedb(properties{1}, properties{2}, ...
                properties{3}, properties{4});
        end % deletedbc
        
        function DB = getcred(filename)
            % Get an open database connection using the credentials from
            % a property file
            parser = inputParser();
            parser.addRequired('filename', @ischar);
            parser.parse(filename);
            properties = cell(...
                edu.utsa.mobbed.ManageDB.loadCredentials(filename));
            DB = Mobbed(properties{1}, properties{2}, ...
                properties{3}, properties{4});
        end % getFromCredentials
        
    end % Static methods
    
end % MobbedDB