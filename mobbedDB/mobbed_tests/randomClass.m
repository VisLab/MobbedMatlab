classdef randomClass
    
    methods(Static)
        
        function UUID = generateUUID()
            value = randi(4294967296);
            UUID = lower(dec2hex(value, 8));
            value = randi(65536);
            UUID = [UUID '-' lower(dec2hex(value, 4))];
            value = randi(65536);
            UUID = [UUID '-' lower(dec2hex(value, 4))];
            value = randi(65536);
            UUID = [UUID '-' lower(dec2hex(value, 4))];
            value = randi(281474976710656);
            UUID = [UUID '-' lower(dec2hex(value, 12))];
        end
        
        function string = generateString()
            length = 200;
            string = char(floor(94*rand(1, length)) + 32);           
        end
    end
    
end

