classdef GENERIC_Modality
    
    methods(Static)
        
        function uniqueEvents = store(DB, datasetUuid, data, eventUuids)
            % Store GENERIC data in database
            
            tStart = tic;
            
            % Store the elements
            if isfield(data, 'element')
                GENERIC_Modality.storeelements(DB, datasetUuid, ...
                    data.element);
                if DB.Verbose
                    fprintf('Elements saved: %f seconds \n', toc(tStart));
                end
            end
            
            uniqueEvents = {};
            % Store the events
            if isfield(data, 'event')
                uniqueEvents = ...
                    GENERIC_Modality.storeevents(DB, datasetUuid, ...
                    data.event, eventUuids);
                if DB.Verbose
                    fprintf('Events saved: %f seconds \n', toc(tStart));
                end
            end
            
            % Store the features
            if isfield(data, 'feature')
                GENERIC_Modality.storefeatures(DB, datasetUuid, ...
                    data.feature);
                if DB.Verbose
                    fprintf('Features saved: %f seconds \n', toc(tStart));
                end
            end
            
            % Store the metadata
            if isfield(data, 'metadata')
                GENERIC_Modality.storemetadata(DB, datasetUuid, ...
                    data.metadata);
                if DB.Verbose
                    fprintf('Metadata saved: %f seconds \n', toc(tStart));
                end
            end
            
            % Store everything in a file
            DbHandler.storefile(DB, datasetUuid, data, false);
            if DB.Verbose
                fprintf('Data saved to DB: %f seconds \n', toc(tStart));
            end
        end % store
        
    end % public methods
    
    methods(Static, Access = private)
        function storeelements(DB, datasetUuid, element)
            % Store the elements for generic dataset
            if isempty(element)
                return;
            end
            position = cell2mat({element.position}');
            label = {element.label}';
            description = {element.description}';
            otherFields = setdiff(fieldnames(element), ...
                {'label', 'position', 'description'})';
            jElement = edu.utsa.mobbed.Elements(DB.getconnection());
            jElement.reset(datasetUuid, 'Generic element group', label, ...
                description, position);
            jElement.addElements();
            for a = 1:length(otherFields)
                values = cellfun(@(x) num2str(x,16), ...
                    {element.(otherFields{a})}', 'UniformOutput', false);
                % convert non-numeric values and empty strings to null
                numerValues = {element.(otherFields{a})}';
                numerValues(cellfun(@(x) ~isnumeric(x) || ...
                    isempty(x),numerValues)) = {[]};
                dblArray = javaArray ('java.lang.Double', ...
                    length(numerValues));
                for b = 1:length(numerValues)
                    if isempty(numerValues{b})
                        dblArray(b) = numerValues{b};
                    else
                        dblArray(b) = java.lang.Double(numerValues{b});
                    end
                end
                jElement.addAttribute(['/' otherFields{a}], dblArray, ...
                    values);
            end
            jElement.save();
        end % storeelements
        
        function uniqueEvents = storeevents(DB, datasetUuid, event, ...
                eventUuids)
            % Store the elements for generic dataset
            if isempty(event)
                return;
            end
            positions = cell2mat({event.position}');
            types = {event.type}';
            startTimes = cell2mat({event.stime}');
            endTimes = cell2mat({event.etime}');
            certainties = cell2mat({event.certainty}');
            uniqueTypes = unique(types);
            eventTypeDescriptions = strcat({'Event type: '}, uniqueTypes);
            eventTags = java.util.HashMap;
            eventTypeTags = java.util.HashMap;
            otherFields = setdiff(fieldnames(event), ...
                {'type', 'position', 'stime', 'etime', 'certainty'})';
            % Now write to the database
            jEvent = edu.utsa.mobbed.Events(DB.getconnection());
            jEvent.reset(datasetUuid, startTimes, endTimes, positions, ...
                positions,  certainties, eventTypeDescriptions, ...
                uniqueTypes, types, eventUuids, eventTags, eventTypeTags);
            uniqueEvents = cell(jEvent.addEvents(true));
            for a = 1:length(otherFields)
                values = cellfun(@num2str, {event.(otherFields{a})}', ...
                    'UniformOutput', false);
                % convert non-numeric values and empty strings to null
                numerValues = {event.(otherFields{a})}';
                numerValues(cellfun(@(x) ~isnumeric(x) ...
                    || isempty(x),numerValues)) = {[]};
                dblArray = javaArray ('java.lang.Double', ...
                    length(numerValues));
                for b = 1:length(numerValues)
                    if isempty(numerValues{b})
                        dblArray(b) = numerValues{b};
                    else
                        dblArray(b) = java.lang.Double(numerValues{b});
                    end
                end
                jEvent.addAttribute(['/' otherFields{a}], dblArray, ...
                    values);
            end
            jEvent.save();
        end % storeevents
        
        function storefeatures(DB, datasetUuid, feature)
            % Store the features for generic dataset
            jFeature = edu.utsa.mobbed.Metadata(DB.getconnection());
            jFeature.reset(datasetUuid);
            otherFields = setdiff(fieldnames(feature), ...
                {'type', 'value', 'description'})';
            for a = 1:length(otherFields)
                values = cellfun(@num2str, {feature.(otherFields{a})}', ...
                    'UniformOutput', false);
                % convert non-numeric values and empty strings to null
                numerValues = {feature.(otherFields{a})}';
                numerValues(cellfun(@(x) ~isnumeric(x) ...
                    || isempty(x),numerValues)) = {[]};
                dblArray = javaArray ('java.lang.Double', ...
                    length(numerValues));
                for b = 1:length(numerValues)
                    if isempty(numerValues{b})
                        dblArray(b) = numerValues{b};
                    else
                        dblArray(b) = java.lang.Double(numerValues{b});
                    end
                end
                jFeature.addAttribute(['/' otherFields{a}], dblArray, ...
                    values);
            end
            jFeature.save();
        end % storefeatures
        
        function storemetadata(DB, datasetUuid, metadata)
            % Store the metadata for generic dataset
            jMetadata = edu.utsa.mobbed.Metadata(DB.getconnection());
            jMetadata.reset(datasetUuid);
            otherFields = fieldnames(metadata);
            for a = 1:length(otherFields)
                values = cellfun(@num2str, ...
                    {metadata.(otherFields{a})}', 'UniformOutput', false);
                % convert non-numeric values and empty strings to null
                numerValues = {metadata.(otherFields{a})}';
                numerValues(cellfun(@(x) ~isnumeric(x) ...
                    || isempty(x),numerValues)) = {[]};
                dblArray = javaArray ('java.lang.Double', ...
                    length(numerValues));
                for b = 1:length(numerValues)
                    if isempty(numerValues{b})
                        dblArray(b) = numerValues{b};
                    else
                        dblArray(b) = java.lang.Double(numerValues{b});
                    end
                end
                jMetadata.addAttribute(['/' otherFields{a}], dblArray, ...
                    values);
            end
            jMetadata.save();
        end % storemetadata
        
    end % Private methods
    
end % GENERIC_Modality

