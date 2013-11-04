classdef CSV_Modality
    
    methods(Static)
        
        function uniqueEvents = store(DB, datasetUuid, data, eventUuids)
            % Store CSV data in database
            tStart = tic;
            % Store the events
            uniqueEvents = ...
                CSV_Modality.storeevents(DB, datasetUuid, data, ...
                eventUuids);
            if DB.Verbose
                fprintf('Events saved: %f seconds \n', toc(tStart));
            end
            filenames = {data.etype_spec.pathname, ...
                data.event_spec.pathname, data.data_spec.pathname};
            % Store as zip file
            DbHandler.storezipfile(DB, datasetUuid, filenames, ...
                isAdditionalData)
            if DB.Verbose
                fprintf('Data saved to DB: %f seconds \n', toc(tStart));
            end
        end % store
        
        function [uniqueTypes, tags, descriptions] = extracttypes(data)
            headerLines = DbHandler.setDefault(0, data, 'header_lines');
            values = splitcsv(data.pathname);
            values = values(1,headerLines+1:end);
            values = vertcat(values{:});
            delimiter = DbHandler.setDefault('|', data, 'delimiter');
            typeColumns = DbHandler.setDefault(1:size(values, 2), data, ...
                'type_columns');
            descriptionColumn = DbHandler.setDefault(0, data, ...
                'description_column');
            tagsColumn = DbHandler.setDefault(0, data.etype_spec, ...
                'tags_column');
            types = delimitTypes(delimiter, values(:,typeColumns));
            uniqueTypes = unique(types);
            tags = extractcsvetypetags(types, tagsColumn, values);
            descriptions = strcat({'Event type: '}, uniqueTypes);
            if descriptionColumn > 0
                descriptions = values(:, descriptionColumn);
            end
        end % extracttypes
        
        function [types, positions, latencies, certainties, tags] = ...
                extractevents(data)
            headerLines = DbHandler.setDefault(0, data, 'header_lines');
            values = splitcsv(data.pathname);
            values = values(1,headerLines+1:end);
            values = vertcat(values{:});
            [rows, columns] = size(values);
            delimiter = DbHandler.setDefault('|', data, 'delimiter');
            typeColumns = DbHandler.setDefault(1:columns, data, ...
                'type_columns');
            latencyColumn = DbHandler.setDefault(0, data, ...
                'latency_column');
            certaintyColumn = DbHandler.setDefault(0, data, ...
                'certainty_column');
            hedTagsColumn = DbHandler.setDefault(0, data, ...
                'hedtags_column');
            userTagsColumn = DbHandler.setDefault(0, data, ...
                'usertags_column');
            types = delimitTypes(delimiter, values(:,typeColumns));
            positions = 1:rows;
            latencies = values(:, latencyColumn);
            certainties = ones(1, size(values,1));
            if certaintyColumn > 0
                certainties = values(:, certaintyColumn);
            end
            event.hedtags(rows) = [];
            if hedTagsColumn > 0
                hedTags = values(:, hedTagsColumn);
                event.hedtags = deal(hedTags{:});
            end
            event.usertags(rows) = [];
            if userTagsColumn > 0
                userTags = values(:, userTagsColumn);
                event.hedtags = deal(userTags{:});
            end
            tags = DbHandler.extracteventtags(event);
        end % extractevents
        
        function uniqueEvents = storeevents(DB, datasetUuid, data, ...
                eventUuids)
            % Store the events of the CSV dataset
            [uniqueTypes, typeTags, typeDescriptions] = ...
                CSV_Modality.extracttypes(data.etype_spec);
            [types, positions, latencies, certainties, eventTags] = ...
                CSV_Modality.extractevents(data);
            jEvent = edu.utsa.mobbed.Events(DB.getconnection());
            jEvent.reset(datasetUuid, latencies, latencies, ...
                positions, positions, certainties, ...
                typeDescriptions, uniqueTypes, types, ...
                eventUuids, eventTags, typeTags);
            uniqueEvents = cell(jEvent.addEvents(false));
        end % storeevents
        
    end
end

