classdef CSV_Modality
    
    methods(Static)
        function uniqueEvents = store(DB, datasetUuid, data, eventUuids)
            % Store CSV data in database
            
            tStart = tic;
            
            % Store the events
            uniqueEvents = ...
                EEG_Modality.storeevents(DB, datasetUuid, data, ...
                eventUuids);
            if DB.Verbose
                fprintf('Events saved: %f seconds \n', toc(tStart));
            end
            
            filenames = {data.standardized_event_types, ...
                data.standardized_events, ...
                data.standardized_event_data};
            
            % Store as zip file
            DbHandler.storezipfile(DB, datasetUuid, filenames, ...
                isAdditionalData)  
            if DB.Verbose
                fprintf('Data saved to DB: %f seconds \n', toc(tStart));
            end
            
        end
                
        function uniqueEvents = storeevents(datasetUuid, data, eventUuids)
            % Store the events of the CSV dataset
            eventTypes = splitcsv(data.standardized_event_types);
            eventTypes = eventTypes(1,2:end);
            eventTypes = vertcat(eventTypes{:});
            uniqueTypes = eventTypes(:, 1);
            descriptions = eventTypes(:, 2);
            eventTypeTags = eventTypes(:, 3:end);
            events = splitcsv(data.standardized_events);
            events = events(1,2:end);
            events = vertcat(events{:});
            [startTimes, endTimes] = events(:, 1);
            ureventPositions = int64(1:size(events, 1))';
            positions = int64(1:size(events, 1))';
            certainties = ones(1, size(events, 1));
            types = events(:, 2);
            eventTags = unique(events(:, 3:end));
            jEvent.reset(datasetUuid, startTimes, endTimes, ...
                ureventPositions, positions, certainties, uniqueTypes, ...
                types, eventUuids, eventTags, eventTypeTags);
            uniqueEvents = cell(jEvent.addEvents(false));
        end % storeevents
                
    end
end

