classdef MobbedCredentials < Mobbed
    %MOBBEDCREDENTIALS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function DB = MobbedCredentials(filename)
            parser = inputParser();
            parser.addRequired('filename', @ischar);
            parser.parse(filename);
            DB = DB@Mobbed();
            
        end
    end
    
    methods(Static)
        function propertyFile = createdbcredentials()
            propertyFile = [];
            credentials = inputdlg({'dbname', 'hostname', ...
                'port', 'username', 'password', 'file name'}, ...
                'Credentials', [1 35; 1 35; 1 4; 1 35; 1 35; 1 35], ...
                {'mobbed', 'localhost', '5432', 'postgres', '', ...
                'config.properties'});
            if ~isempty(credentials)
                directory = uigetdir();
                if ~isempty(directory)                    
                    propertyFile = [directory '\' credentials{6}];
                end
            end
        end
    end
    
end

