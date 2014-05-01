classdef randomClass
    
    methods(Static)
        
        function UUID = generateUUID()
            UUID = char(java.util.UUID.randomUUID());
        end
        
    end
    
end

