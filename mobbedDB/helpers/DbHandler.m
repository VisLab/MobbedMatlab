classdef DbHandler
    
    methods(Static)
        
        function addjavapath()
            % Add all of jar files in the jars subdirectory to java path
            jarPath = [fileparts(which('Mobbed')) filesep 'jars'];
            jarFiles = dir([jarPath filesep '*.jar']);
            jarFileNames = {jarFiles.name};
            jarFilePaths = cellfun(@(x) fullfile(jarPath, x), ...
                jarFileNames, 'UniformOutput', false);
            warning off all;
            try
                javaaddpath(jarFilePaths(:));
            catch mex %#ok<NASGU>
            end
            warning on all;
        end % addjavapath
        
        function [mName, mUUID] = checkmodality(DB, modalityUUID)
            % Checks the given modality
            expr = ['^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-'...
                '[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'...
                '[0-9a-fA-F]{12}$'];
            if isempty(regexpi(modalityUUID, expr))
                inModality.modality_name = modalityUUID;
            else
                inModality.modality_uuid = modalityUUID;
            end
            outModality = getdb(DB, 'modalities', 1, inModality);
            if isempty(outModality)
                throw(MException('getModality:inValidModality', ...
                    'Modality does not exist'));
            end
            mName = outModality.modality_name;
            mUUID = outModality.modality_uuid;
        end % checkmodality
        
        function jArray = createjaggedarray(array)
            % Creates a jagged java array
            if isempty(array)
                jArray = [];
                return;
            end
            if iscell(array)
                arrayLength = length(array);
                jArray = javaArray('java.lang.String[]', arrayLength);
                for a = 1:arrayLength
                    if iscellstr(array{a})
                        cellSize = length(array{a});
                        currentCell = array{a};
                        jArray2 = javaArray('java.lang.String', cellSize);
                        for b = 1:cellSize
                            jArray2(b) = java.lang.String(currentCell{b});
                        end
                    else
                        jArray2 = javaArray('java.lang.String', 1);
                        jArray2(1) = java.lang.String(array{a});
                    end
                    jArray(a) = jArray2;
                end
            else
                jArray = javaArray('java.lang.String[]', 1);
                jArray2 = javaArray('java.lang.String', 1);
                jArray2(1) = java.lang.String(array);
                jArray(1) = jArray2;
            end
        end % createjaggedarray
        
        function eventTags = extractEventTags(event)
            eventTags = cell(1, length(event));
            userTags = cell(1, length(event));
            hedTags = cell(1, length(event));
            if isfield(event, 'usertags')
                userTags = cellfun(@(x)strsplit({event.usertags}, ','), ...
                    'UniformOutput', false);
            end
            if isfield(event, 'hedtags')
                hedTags = cellfun(@(x)strsplit({event.hedtags}, ','), ...
                    'UniformOutput', false);
            end
            for a = 1: length(event)
            eventTags{a} = union(userTags{a}, hedTags{a});
            end
            eventTags = createjaggedarray(eventTags);
        end % extractEventTags
        
        function typeTagMap = extracttagmap(data)
            % Extracts the type tagMap
            typeTagMap = [];
            eventFields = {data.etc.tags.map.field};
            if any(strcmpi('type', eventFields))
                typeIndecie = strcmpi('type', eventFields);
                typeTagMap = data.etc.tags.map(typeIndecie);
                
            end
        end % extracttagmap
        
        function [uniqueTypes, tags] = extracttagmaptags(uniqueTypes, ...
                tagMap)
            % Extracts the unique types from the type tagMap
            tagMapTypes = {tagMap.values.label};
            tagMapTags = {tagMap.values.tags};
            indices = ismember(tagMapTypes, uniqueTypes);
            uniqueTypes = tagMapTypes(indices);
            tags = tagMapTags(indices);
            tags = DbHandler.tags2jaggedarray(tags);
        end % extracttagmaptags
        
        function [values, doubleValues, range] = ...
                extractvalues(structure, ...
                doubleColumns, isInsert)
            % extracts values from a structure array
            numColumns = length(doubleColumns);
            doubleValues = [];
            range = [];
            if isInsert
                if numColumns > 0
                    numStructs = length(structure);
                    doubleValues = javaArray('java.lang.Double', ...
                        numStructs, numColumns);
                    for a = 1:numStructs
                        for b = 1:numColumns
                            if isempty(structure(a).(doubleColumns{b}))
                                doubleValues(a,b) = [];
                            else
                                doubleValues(a,b) = java.lang.Double(...
                                    structure(a).(doubleColumns{b}));
                            end
                        end
                    end
                end
                structure = rmfield(structure, doubleColumns);
                values = cellfun(@num2str, ...
                    squeeze(struct2cell(structure))', 'UniformOutput', ...
                    false);
            else
                if numColumns > 0
                    range = ones(numColumns, 2);
                    doubleValues = javaArray('java.lang.Double[]', ...
                        numColumns);
                    for a = 1:numColumns
                        if isstruct(structure.(doubleColumns{a}))
                            arraySize = ...
                                length(...
                                structure.(doubleColumns{a}).values);
                            range(a,:) = ...
                                structure.(doubleColumns{a}).range;
                            currentArray = ...
                                structure.(doubleColumns{a}).values;
                            jArray2 = javaArray('java.lang.Double', ...
                                arraySize);
                            for b = 1:arraySize
                                jArray2(b) = ...
                                    java.lang.Double(currentArray(b));
                            end
                        else
                            arraySize = ...
                                length(structure.(doubleColumns{a}));
                            range(a,:) = [-eps('double'), eps('double')];
                            currentArray = structure.(doubleColumns{a});
                            jArray2 = javaArray('java.lang.Double', ...
                                arraySize);
                            for b = 1:arraySize
                                jArray2(b) = ...
                                    java.lang.Double(currentArray(b));
                            end
                        end
                        doubleValues(a) = jArray2;
                    end
                end
                structure = rmfield(structure, doubleColumns);
                values = DbHandler.createjaggedarray(...
                    struct2cell(structure));
            end
        end % extractvalues
        
        function string = reformatstring(string)
            % Convert character string to cellstr
            if ischar(string), string = cellstr(string); end;
        end % reformatstring
        
        function data = retrievedatadef(DB, datadefUuid, datadefFormat, ...
                additionalData)
            % Retrieves the data associated with a datadef
            if strcmpi(datadefFormat, 'EXTERNAL')
                data = DbHandler.retrievefile(DB, datadefUuid, ...
                    additionalData);
            elseif strcmpi(datadefFormat, 'NUMERIC_STREAM')
                data = DbHandler.retrievenumericstream(DB, datadefUuid);
            elseif strcmpi(datadefFormat, 'NUMERIC_VALUE')
                data = double(...
                    edu.utsa.mobbed.Datadefs.retrieveNumericValue(...
                    DB.getconnection(), datadefUuid));
            elseif strcmpi(datadefFormat, 'XML_VALUE')
                data = char(edu.utsa.mobbed.Datadefs.retrieveXMLValue(...
                    DB.getconnection(), datadefUuid));
            else throw(MException('retrieveDataDef:InvalidFormat', ...
                    'Datadef format is invalid'));
            end
        end % retrievedatadef
        
        function file = retrievefile(DB, entityUUID, isAdditionalData)
            % Retrieves data from a external file
            fileName = [tempname '.mat'];
            edu.utsa.mobbed.Datadefs.retrieveBlob(DB.getconnection(), ...
                fileName, entityUUID, isAdditionalData);
            if exist(fileName, 'file')
                load(fileName);
                file = data;
                delete(fileName);
            else
                file = [];
            end
        end % retrievefile
        
        function data = retrievenumericstream(DB, data_def_uuid)
            % Retrieves numeric stream from database
            jNumericData = ...
                edu.utsa.mobbed.NumericStreams(DB.getconnection());
            jNumericData.reset(data_def_uuid);
            numElements = ...
                edu.utsa.mobbed.NumericStreams.getArrayLength(...
                DB.getconnection(), data_def_uuid);
            maxPosition = jNumericData.getMaxPosition();
            width = 10000;
            k = 1;
            data = zeros(numElements, maxPosition);
            while k < maxPosition
                endTime = min(k + width, maxPosition + 1);
                signal_data = jNumericData.retrieveByPosition(k, ...
                    endTime, numElements);
                data(:,k:endTime-1)= signal_data';
                k = k + width;
            end
        end % retrievenumericstream
        
        function storedatadef(DB, datadefUuid, datadef, timestamps)
            % Stores data associated with a datadef
            if strcmpi(datadef.datadef_format, 'EXTERNAL')
                DbHandler.storefile(DB, datadefUuid, datadef.data, false)
            elseif strcmpi(datadef.datadef_format, 'NUMERIC_STREAM')
                if isempty(datadef.datadef_sampling_rate) && ...
                        isempty(timestamps)
                    throw (MException('DbHandler:InvalidSamplingRate', ...
                        'sample rate and timestamps are not present'));
                end
                if  ~isempty(datadef.datadef_sampling_rate)
                    if datadef.datadef_sampling_rate < 0
                        datadef.datadef_sampling_rate = 1;
                    end
                    times = zeros(1,size(datadef.data,2));
                    for a = 2:length(times)
                        times(a) = (a-1)/datadef.datadef_sampling_rate;
                    end
                else
                    times = timestamps;
                end
                DbHandler.storenumericstream(DB, datadefUuid, ...
                    datadef.data, times);
            elseif strcmpi(datadef.datadef_format, 'NUMERIC_VALUE')
                edu.utsa.mobbed.Datadefs.storeNumericValue(...
                    DB.getconnection(), datadefUuid, datadef.data);
            elseif strcmpi(datadef.datadef_format, 'XML_VALUE')
                edu.utsa.mobbed.Datadefs.storeXMLValue(...
                    DB.getconnection(), datadefUuid, datadef.data);
            else throw (MException('retrieveDataDef:InvalidFormat', ...
                    'Datadef format is invalid'));
            end
        end % storedatadef
        
        function storefile(DB, entityUuid, data, ...
                isAdditionalData) %#ok<INUSL>
            % Store data in a external file
            fileName = [tempname '.mat'];
            save(fileName, 'data', '-v7.3');
            edu.utsa.mobbed.Datadefs.storeBlob(DB.getconnection(), ...
                fileName, entityUuid, isAdditionalData);
            delete(fileName);
        end % storefile
        
        function storenumericstream(DB, dataDefUuid, data, times)
            % Stores numeric stream
            numFrames = length(data);
            jNumericStream = edu.utsa.mobbed.NumericStreams(...
                DB.getconnection());
            jNumericStream.reset(dataDefUuid);
            k = 1;
            while(k < numFrames)
                eIndex = min(k + 10000 - 1, numFrames);
                signals = double(data(:, k:eIndex));
                signalTimes = times(k:eIndex);
                jNumericStream.save(signals, signalTimes, int64(k));
                k = k + 10000;
            end
        end % storenumericstream
        
        function jArray = tags2jaggedarray(cellArray)
            % Puts the type tagMap tags in a jagged array
            cellArrayLength = length(cellArray);
            jArray = javaArray('java.lang.String[]', cellArrayLength);
            for a = 1:cellArrayLength
                if iscellstr(cellArray{a})
                    cellSize = length(cellArray{a});
                    currentCell = cellArray{a};
                    jArray2 = javaArray('java.lang.String', cellSize);
                    for b = 1:cellSize
                        jArray2(b) = java.lang.String(currentCell{b});
                    end
                else
                    jArray2 = javaArray('java.lang.String', 1);
                    jArray2(1) = java.lang.String(cellArray{a});
                end
                jArray(a) = jArray2;
            end
        end % tags2jaggedarray
        
        function success = validateuuids(UUIDs)
            % Validates a cellstr of UUIDs
            if isempty(UUIDs), success = true; return; end;
            UUIDs = DbHandler.reformatstring(UUIDs);
            expr = ['^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-'...
                '[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'];
            if any(cellfun('isempty', (regexpi(UUIDs,expr))))
                throw(MException('validateUUID:InvalidFormat', ...
                    'UUIDs is incorrectly formatted'));
            end
            if any(cellfun('isempty', UUIDs))
                throw(MException('validateUUID:InvalidType', ...
                    'UUIDs can not be empty'));
            end
            success = true;
        end % validateuuids
        
    end % static methods
    
end

