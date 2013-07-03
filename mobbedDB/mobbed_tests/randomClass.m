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
            symbols = ['a':'z' 'A':'Z' '0':'9'];
            MAX_ST_LENGTH = 50;
            stLength = randi(MAX_ST_LENGTH);
            nums = randi(numel(symbols),[1 stLength]);
            string = symbols (nums);
        end
    end
    
end

