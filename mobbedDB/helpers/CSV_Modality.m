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
            DbHandler.storezipfile(DB, datasetUuid, filenames, false);
            if DB.Verbose
                fprintf('Data saved to DB: %f seconds \n', toc(tStart));
            end
        end % store
        
        function [uniqueTypes, tags, descriptions] = extracttypes(data)
            headerLines = DbHandler.setDefault(0, data, 'header_lines');
            values = csv2cell(data.pathname,'fromfile');
            values = values(headerLines+1:end, :);
            [~, columns] = size(values);
            delimiter = DbHandler.setDefault('|', data, 'delimiter');
            typeColumns = DbHandler.setDefault(1:columns, data, ...
                'type_columns');
            descriptionColumn = DbHandler.setDefault(0, data, ...
                'description_column');
            tagsColumn = DbHandler.setDefault(0, data, 'tags_column');
            types = DbHandler.delimitValues(delimiter, ...
                values(:,typeColumns));
            uniqueTypes = unique(types);
            tags = DbHandler.extractcsvetypetags(types, tagsColumn, ...
                values);
            descriptions = strcat({'Event type: '}, uniqueTypes);
            if descriptionColumn > 0 && descriptionColumn <= columns
                descriptions = values(:, descriptionColumn);
            end
        end % extracttypes
        
        function [types, positions, latencies, certainties, tags] = ...
                extractevents(data)
            headerLines = DbHandler.setDefault(0, data, 'header_lines');
            values = csv2cell(data.pathname,'fromfile');
            values = values(headerLines+1:end, :);
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
            types = DbHandler.delimitValues(delimiter, ...
                values(:,typeColumns));
            positions = int64(1:rows);
            latencies = cellfun(@str2num, values(:, latencyColumn))';
            certainties = ones(1, size(values,1));
            if certaintyColumn > 0 && certaintyColumn <= columns
                certainties =  cellfun(@str2num, ...
                    values(:, certaintyColumn))';
            end
            event(rows).hedtags = [];
            if hedTagsColumn > 0 && hedTagsColumn <= columns
                hedTags = values(:, hedTagsColumn);
                [event.hedtags] = deal(hedTags{:});
            end
            event(rows).usertags = [];
            if userTagsColumn > 0 && userTagsColumn <= columns
                userTags = values(:, userTagsColumn);
                [event.hedtags] = deal(userTags{:});
            end
            tags = DbHandler.extracteventtags(event);
        end % extractevents
        
        function uniqueEvents = storeevents(DB, datasetUuid, data, ...
                eventUuids)
            % Store the events of the CSV dataset
            [uniqueTypes, typeTags, typeDescriptions] = ...
                CSV_Modality.extracttypes(data.etype_spec);
            [types, positions, latencies, certainties, eventTags] = ...
                CSV_Modality.extractevents(data.event_spec);
            jEvent = edu.utsa.mobbed.Events(DB.getconnection());
            jEvent.reset(datasetUuid, latencies, latencies, ...
                positions, positions, certainties, ...
                typeDescriptions, uniqueTypes, types, ...
                eventUuids, eventTags, typeTags);
            uniqueEvents = cell(jEvent.addEvents(true));
        end % storeevents
        
    end
end

