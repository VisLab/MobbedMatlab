classdef EEG_Modality
    
    methods(Static)
               
        function uniqueEvents = store(DB, datasetUuid, data, eventUuids)
            % Store EEG data in database
            
            tStart = tic;
           
            % Store the elements
            EEG_Modality.storeElements(DB, datasetUuid, ...
                size(data.data, 1), data.chanlocs);
            if DB.Verbose
                fprintf('Channels saved: %f seconds \n', toc(tStart));
            end
            
            % Store the events
            uniqueEvents = EEG_Modality.storeEvents(DB, ...
                datasetUuid, data.event, eventUuids);
            if DB.Verbose
                fprintf('Events saved: %f seconds \n', toc(tStart));
            end
            
            % Store as file 
            DbHandler.storeFile(DB, datasetUuid, data, ...
                true);
            if DB.Verbose
                fprintf('File saved: %f seconds \n', toc(tStart));
            end
            
        end % store
        
    end % static methods
    
    
    methods (Static, Access = private)
                      
        function storeElements(DB, datasetUuid, numChans, chanlocs)
            % Store the elements for EEG dataset
            position = (1:numChans)';
            if ~isempty(chanlocs)
                if length(chanlocs)~= numChans
                    throw (MException(['EEG_Modality:' ...
                        'EEGChannelLocsStructureInvalid'], ...
                        'chanlocs size doesn''t agree with data size'));
                end
                label = {chanlocs.labels}';
                fields = fieldnames(chanlocs);
                otherFields = setdiff(fields, {'labels'});
            else
                label = strtrim(cellstr(num2str(position)));
                otherFields = [];
            end
            description = strcat({'EEG channel: '}, label);
            jElement = mobbed.Elements(DB.getConnection());
            jElement.reset(datasetUuid, 'chanlocs',  [], 'EEG Cap', ...
                label, description, position);
            jElement.addElements();
            if ~isempty(chanlocs)
                for a = 1:length(otherFields)
                    values = cellfun(@(x) num2str(x, 16), ...
                        {chanlocs.(otherFields{a})}', ...
                        'UniformOutput', false);
                    % convert non-numeric values and empty strings to null
                    numerValues = {chanlocs.(otherFields{a})}';
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
            end
            jElement.save();
        end % storeElements
        
        
        function uniqueEvents = storeEvents(DB, datasetUuid, event, eventUuids)
            % Store the events for EEG dataset
            if isempty(event)
                uniqueEvents = {};
                return;
            end
            [startTimes, endTimes] = ...
                deal(arrayfun(@(x) x.latency/1000, event));
            types = cellfun(@num2str, {event.type}', ...
                'UniformOutput', false);
            certainties = ones(1, length(event));
            positions = int64(1:length(types))';
            fields = fieldnames(event);
            otherFields = setdiff(fields, {'type'; 'latency'});
            uniqueTypes = unique(types);
            jEvent = mobbed.Events(DB.getConnection());
            jEvent.reset(datasetUuid, 'event', [], uniqueTypes, types, ...
                positions, startTimes, endTimes, certainties, eventUuids);
            uniqueEvents = cell(jEvent.addEvents())';
            for a = 1:length(otherFields)
                values = cellfun(@(x) num2str(x, 16), ...
                    {event.(otherFields{a})}', 'UniformOutput', false);
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
        
    end % private static methods
    
end % EEG_Modality

