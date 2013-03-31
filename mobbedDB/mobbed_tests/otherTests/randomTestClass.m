classdef randomTestClass
    
    methods(Static)
        
        function UUID = generateRandomUUID
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
        
    end
    
end

