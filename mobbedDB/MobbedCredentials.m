classdef MobbedCredentials < Mobbed
    
    methods
        
        function DB = MobbedCredentials(filename)
            parser = inputParser();
            parser.addRequired('filename', @ischar);
            parser.parse(filename);
            properties = cell(...
                edu.utsa.mobbed.ManageDB.loadcredentials(filename));
            DB = DB@Mobbed(properties{1}, properties{2}, ...
                properties{3}, properties{4});
        end % MobbedCredentials
        
    end % Public methods
    
    methods(Static)
        
        function createdb(filename, script)
            parser = inputParser();
            parser.addRequired('filename', @ischar);
            parser.parse(filename);
            properties = cell(...
                edu.utsa.mobbed.ManageDB.loadcredentials(filename));
            Mobbed.createdb(properties{1}, properties{2}, ...
                properties{3}, properties{4}, script);
        end % createdb
        
        function propertyFile = createdbcredentials()
            propertyFile = [];
            credentials = inputdlg({'filename', 'dbname', 'hostname', ...
                'port', 'username', 'password'}, ...
                'Credentials', [1 35; 1 35; 1 35; 1 4; 1 35; 1 35], ...
                {'config.properties', 'mobbed', 'localhost', '5432', ...
                'postgres', 'password'});
            if ~isempty(credentials)
                directory = uigetdir();
                if ~isempty(directory)
                    if ~isempty(credentials{4})
                        credentials{3} = [credentials{3} ':' ...
                            credentials{4}];
                    end
                    propertyFile = [directory '\' credentials{1}];
                    edu.utsa.mobbed.ManageDB.createdbcredentials(...
                        propertyFile, credentials{2}, credentials{3}, ...
                        credentials{5}, credentials{6});
                end
            end
        end % createdbcredentials
        
        function deletedb(filename)
            parser = inputParser();
            parser.addRequired('filename', @ischar);
            parser.parse(filename);
            properties = cell(...
                edu.utsa.mobbed.ManageDB.loadcredentials(filename));
            Mobbed.deletedb(properties{1}, properties{2}, ...
                properties{3}, properties{4});
        end % deletedb
        
    end % Static methods
    
    
    
end

