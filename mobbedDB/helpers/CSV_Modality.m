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
            eTypeHeaderLines = 0;
            if isfield(data.etype_spec, 'header_lines') && ...
                    ~isempty(data.etype_spec.header_lines)                
                eTypeHeaderLines = data.etype_spec.header_lines;
            end
            eventTypeValues = splitcsv(data.etype_spec.pathname);
            eventTypeValues = eventTypeValues(1,eTypeHeaderLines+1:end);
            eventTypeValues = vertcat(eventTypeValues{:});
            eTypeDelimiter = '|';
            if isfield(data.etype_spec, 'delimiter') && ...
                    ~isempty(data.etype_spec.delimiter)
                eTypeDelimiter = data.etype_spec.delimiter;
            end
            eTypeColumns = 1:size(eventTypeValues, 2);
            if isfield(data.etype_spec, 'type_columns') && ...
                    ~isempty(data.etype_spec.type_columns)
                eTypeColumns = data.etype_spec.type_columns;
            end
            eTypeDescriptionColumn = 0;
            if isfield(data.etype_spec, 'description_column') && ...
                    ~isempty(data.etype_spec.description_column)
                eTypeDescriptionColumn = data.etype_spec.description_column;
            end
            eTypeTagsColumn = 0;
            if isfield(data.etype_spec, 'tags_column') && ...
                    ~isempty(data.etype_spec.tags_column)
                eTypeTagsColumn = data.etype_spec.tags_column;
            end
            jEvent.reset(datasetUuid, startTimes, endTimes, ...
                ureventPositions, positions, certainties, ...
                eventTypeDescriptions, uniqueTypes, types, eventUuids, ...
                eventTags, eventTypeTags);
            uniqueEvents = cell(jEvent.addEvents(false));
        end % storeevents
                
    end
end

