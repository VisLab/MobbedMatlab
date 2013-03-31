classdef SIMPLE_Modality
    % Represents datasets that are only stored as blobs and not exploded
    
    methods(Static)       
        function uniqueEvents = store(DB, datasetUuid, data, eventUuids)  %#ok<INUSD>       
            tStart = tic;        
            uniqueEvents = {};
            DbHandler.storeFile(DB, datasetUuid, data, true);
            if DB.Verbose
                fprintf('Data saved to DB: %f seconds \n', toc(tStart));
            end   
        end % store    
    end % static methods   
end % SIMPLE_Modality

