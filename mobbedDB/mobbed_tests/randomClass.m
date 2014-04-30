classdef randomClass
    
    methods(Static)
        
        function UUID = generateUUID()
            UUID = char(java.util.UUID.randomUUID());
        end
        
        function string = generateString()
            string = char(java.util.Date());
        end
    end
    
end

