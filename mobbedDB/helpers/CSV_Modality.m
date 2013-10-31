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
        end % store
        
        function [uniqueEventTypes, eventTypeTags, ...
                eventTypeDescriptions] = extractetypevalues(data)
            eTypeHeaderLines = setDefault(0, data.etype_spec, ...
                'header_lines');
            eTypeValues = splitcsv(data.etype_spec.pathname);
            eTypeValues = eTypeValues(1,eTypeHeaderLines+1:end);
            eTypeValues = vertcat(eTypeValues{:});
            eTypeDelimiter = setDefault('|', data.etype_spec, 'delimiter');
            eTypeColumns = setDefault(1:size(eTypeValues, 2), ...
                data.etype_spec, 'type_columns');
            eTypeDescriptionColumn = setDefault(0, data.etype_spec, ...
                'description_column');
            eTypeTagsColumn = setDefault(0, data.etype_spec, ...
                'tags_column');
            eTypeTypes = delimitTypes(eTypeDelimiter, ...
                eTypeValues(:,eTypeColumns));
            uniqueEventTypes = unique(eTypeTypes);
            eventTypeTags = extractcsvetypetags(eTypeTypes, ...
                eTypeTagsColumn, eTypeValues);
            eventTypeDescriptions = strcat({'Event type: '}, uniqueTypes);
            if eTypeDescriptionColumn > 0
                eventTypeDescriptions = ...
                    eTypeValues(:, eTypeDescriptionColumn);
            end
        end % extractetypevalues
        
        function uniqueEvents = storeevents(datasetUuid, data, eventUuids)
            % Store the events of the CSV dataset
            [uniqueEventTypes, eventTypeTags, eventTypeDescriptions] = ...
                extractetypevalues(data.etype_spec);
            jEvent.reset(datasetUuid, startTimes, endTimes, ...
                ureventPositions, positions, certainties, ...
                eventTypeDescriptions, uniqueEventTypes, types, ...
                eventUuids, eventTags, eventTypeTags);
            uniqueEvents = cell(jEvent.addEvents(false));
        end % storeevents
        
    end
end

