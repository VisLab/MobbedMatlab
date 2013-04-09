classdef MobbedCredentials < Mobbed
    %MOBBEDCREDENTIALS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function DB = MobbedCredentials(filename, varargin)
            parser = inputParser();
            parser.addRequired('filename', @ischar);
            parser.parse(filename);
            propertyArray = cell(...
                edu.utsa.mobbed.ManageDB.loadcredentials(filename));
            DB = DB@Mobbed(propertyArray{1}, propertyArray{2}, ...
                propertyArray{3}, propertyArray{4});            
        end
    end
    
    methods(Static)
        function propertyFile = createdbcredentials()
            propertyFile = [];
            credentials = inputdlg({'filename', 'dbname', 'hostname', ...
                'port', 'username', 'password'}, ...
                'Credentials', [1 35; 1 35; 1 35; 1 4; 1 35; 1 35], ...
                {'config.properties', 'mobbed', 'localhost', '5432', ...
                'postgres', 'password', ...
                });
            if ~isempty(credentials)
                directory = uigetdir();
                if ~isempty(directory) 
                    propertyFile = [directory '\' credentials{1}];
                    edu.utsa.mobbed.ManageDB.createdbcredentials(...
                        propertyFile, credentials{2}, credentials{3}, ...
                        credentials{4}, credentials{5}, credentials{6});                     
                end
            end
        end
    end
    
end

