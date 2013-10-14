classdef EEG_Modality
    
    methods(Static)
        
        function uniqueEvents = store(DB, datasetUuid, data, eventUuids)
            % Store EEG data in database
            
            tStart = tic;
            
            % Store the channels
            if isfield(data, 'chanlocs')
                EEG_Modality.storeelements(DB, datasetUuid, ...
                    size(data.data, 1), data.chanlocs);
                if DB.Verbose
                    fprintf('Channels saved: %f seconds \n', toc(tStart));
                end
            end
            
            % Extract the tags for event types
            typeTagMap = [];
            if isfield(data.etc, 'tags')
                typeTagMap = DbHandler.extracttagmap(data);
            end
            
            % Create Events object for urevent and event
            jEvent = edu.utsa.mobbed.Events(DB.getconnection());
            
            % Store the urevents
            if isfield(data, 'urevent')
                uniqueEvents = ...
                    EEG_Modality.storeurevents(jEvent, ...
                    datasetUuid, data.urevent, eventUuids, typeTagMap);
                if DB.Verbose
                    fprintf('Original events saved: %f seconds \n', ...
                        toc(tStart));
                end
            end
            
            % Store the events
            if isfield(data, 'event')
                uniqueEvents = EEG_Modality.storeevents(jEvent, ...
                    datasetUuid, data.event, uniqueEvents, typeTagMap);
                if DB.Verbose
                    fprintf('Events saved: %f seconds \n', toc(tStart));
                end
            end
            
            % Store as file
            DbHandler.storefile(DB, datasetUuid, data, true);
            if DB.Verbose
                fprintf('Data saved to DB: %f seconds \n', toc(tStart));
            end
            
        end % store
        
    end % static methods
    
    
    methods (Static, Access = private)
        
        function storeelements(DB, datasetUuid, numChans, chanlocs)
            % Store the elements of the EEG dataset
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
            jElement = edu.utsa.mobbed.Elements(DB.getconnection());
            jElement.reset(datasetUuid, 'EEG Cap', label, description, ...
                position);
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
                    jElement.addAttribute(['/' otherFields{a}], ...
                        dblArray, values);
                end
            end
            jElement.save();
        end % storeelements
        
        
        function uniqueEvents = storeevents(jEvent, datasetUuid, event, ...
                eventUuids, typeTagMap)
            % Store the events of the EEG dataset
            if isempty(event)
                uniqueEvents = {};
                return;
            end
            [startTimes, endTimes] = ...
                deal(arrayfun(@(x) x.latency/1000, event));
            types = cellfun(@num2str, {event.type}', ...
                'UniformOutput', false);
            certainties = ones(1, length(event));
            ureventPositions = {event.urevent};
            ureventPositions = int64(cell2mat(ureventPositions));
            positions = int64(1:length(types))';
            fields = fieldnames(event);
            otherFields = setdiff(fields, {'type'; 'latency'});
            uniqueTypes = unique(types);
            tags = [];
            if ~isempty(typeTagMap)
                [uniqueTypes, tags] = ...
                    DbHandler.extracttagmaptags(uniqueTypes, typeTagMap);
            end
            jEvent.reset(datasetUuid, startTimes, endTimes, ...
                ureventPositions, positions, certainties, uniqueTypes, ...
                types, eventUuids, tags);
            uniqueEvents = cell(jEvent.addNewTypes());
            jEvent.addEvents(false);
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
                jEvent.addAttribute(['/' otherFields{a}], dblArray, ...
                    values);
            end
            jEvent.save();
        end % storeevents
        
        function uniqueEvents = storeurevents(jEvent, datasetUuid, ...
                urevent, eventUuids, typeTagMap)
            % Store the urevents of the EEG dataset
            if isempty(urevent)
                uniqueEvents = {};
                return;
            end
            [startTimes, endTimes] = ...
                deal(arrayfun(@(x) x.latency/1000, urevent));
            types = cellfun(@num2str, {urevent.type}', ...
                'UniformOutput', false);
            certainties = ones(1, length(urevent));
            positions = int64(1:length(types))';
            uniqueTypes = unique(types);
            tags = [];
            if ~isempty(typeTagMap)
                [uniqueTypes, tags] = ...
                    DbHandler.extracttagmaptags(uniqueTypes, typeTagMap);
            end
            jEvent.reset(datasetUuid, startTimes, endTimes, positions, ...
                positions,  certainties, uniqueTypes, types, ...
                eventUuids, tags);
            uniqueEvents = cell(jEvent.addNewTypes());
            jEvent.addEvents(true);
            jEvent.save();
        end % storeurevents
        
    end % private static methods
    
end % EEG_Modality

