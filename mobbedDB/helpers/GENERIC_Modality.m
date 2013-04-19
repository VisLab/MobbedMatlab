classdef GENERIC_Modality
    
    methods(Static)
        
        function uniqueEvents = store(DB, datasetUuid, data, eventUuids)
            % Store GENERIC data in database
            
            tStart = tic;
            
            % Store the elements
            if isfield(data, 'element')
                GENERIC_Modality.storeElements(DB, datasetUuid, ...
                    data.element);
                if DB.Verbose
                    fprintf('Elements saved: %f seconds \n', toc(tStart));
                end
            end
            
            % Store the events
            if isfield(data, 'event')
                uniqueEvents = ...
                    GENERIC_Modality.storeEvents(DB, datasetUuid, ...
                    data.event, eventUuids);
                if DB.Verbose
                    fprintf('Events saved: %f seconds \n', toc(tStart));
                end
                
            else
                uniqueEvents = {};
            end
            
            % Store the metadata
            if isfield(data, 'metadata')
                GENERIC_Modality.storeMetadata(DB, datasetUuid, ...
                    data.metadata);
                if DB.Verbose
                    fprintf('Metadata saved: %f seconds \n', toc(tStart));
                end
            end
            
            % Store everything in a file
            DbHandler.storeFile(DB, datasetUuid, data, true);
            if DB.Verbose
                fprintf('Data saved to DB: %f seconds \n', toc(tStart));
            end
        end % store
        
    end % public methods
    
    methods(Static, Access = private)
        function storeElements(DB, datasetUuid, element)
            % Store the elements for generic dataset
            if isempty(element)
                return;
            end
            position = cell2mat({element.position}');
            label = {element.label}';
            description = {element.description}';
            otherFields = setdiff(fieldnames(element), ...
                {'label', 'position', 'description'})';
            jElement = edu.utsa.mobbed.Elements(DB.getConnection());
            jElement.reset(datasetUuid, 'element', [], ...
                'Generic element group', label, description, position);
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
                jElement.addAttribute(otherFields{a}, dblArray, values);
            end
            jElement.save();
        end % storeElements
        
        function uniqueEvents = storeEvents(DB, datasetUuid, event, eventUuids)
            % Store the elements for generic dataset
            if isempty(event)
                return;
            end
            positions = cell2mat({event.position}');
            types = {event.type}';
            startTimes = cell2mat({event.stime}');
            endTimes = cell2mat({event.etime}');
            certainties = cell2mat({event.certainty}');
            parentUuids = cell(1, length(event));
            [parentUuids{:}] = ...
                deal(char(edu.utsa.mobbed.ManageDB.noParentUuid));
            uniqueTypes = unique(types);
            otherFields = setdiff(fieldnames(event), ...
                {'type', 'position', 'stime', 'etime', 'certainty'})';
            % Now write to the database
            jEvent = edu.utsa.mobbed.Events(DB.getConnection());
            jEvent.reset(datasetUuid, 'event', [], uniqueTypes, types, ...
                positions, startTimes, endTimes, certainties, ...
                eventUuids, parentUuids);
            uniqueEvents = cell(jEvent.addNewTypes());
            jEvent.addEvents();
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
                jEvent.addAttribute(otherFields{a}, dblArray, values);
            end
            jEvent.save();
        end % storeEvents
        
        function storeMetadata(DB, datasetUuid, metadata)
            % Store the metadata for generic dataset
            jMetadata = edu.utsa.mobbed.Metadata(DB.getConnection());
            jMetadata.reset(datasetUuid, 'metadata');
            otherFields = fieldnames(metadata);
            for a = 1:length(otherFields)
                value = num2str(metadata.(otherFields{a}));
                % convert non-numeric values and empty strings to null
                numerValue = metadata.(otherFields{a});
                if ~isnumeric(numerValue) || isempty(numerValue)
                    numerValue = [];
                end
                dblArray = javaArray ('java.lang.Double', 1);
                if isempty(numerValue)
                    dblArray(1) = numerValue;
                else
                    dblArray(1) = java.lang.Double(numerValue);
                end
                jMetadata.addAttribute(otherFields{a}, dblArray, value);
            end
            jMetadata.save();
        end % storeMetadata
        
    end % private methods
    
end % GENERIC_Modality

