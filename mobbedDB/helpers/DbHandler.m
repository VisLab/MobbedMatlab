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
        
        function default = setDefault(default, structure, field)
            if isfield(structure, field) && ~isempty(structure.(field))
                default = data.etype_spec.delimiter;
            end
        end
        
        function delimitedTypes = delimitTypes(delimiter, types)
            delimitedTypes = cellfun(@num2str, types(:, 1), ...
                'UniformOutput', false);
            for a = 1:size(types,1)
                for b = 2:size(types,2)
                    delimitedTypes{a} = ...
                        [delimitedTypes{a} delimiter num2str(types{a,b})];
                end
            end
        end
        
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
        
        function eventTypeTags = extractcsvetypetags(types, tagsColumn, ...
                eventTypeValues)
            eventTypeTags = initializetypehashmap(unique(types));
            if tagsColumn > 0
                tagValues = eventTypeValues(:, tagsColumn);
                tagValues = cellfun(@(x) strsplit(x, ','), tagValues, ...
                    'UniformOutput', true);
                for a = 1:length(types)
                    typeTags = eventTypeTags.get(types{a});
                    if ~isempty(typeTags)
                        typeTags = cell(typeTags);
                    end
                    combinedTags = union(typeTags, tagValues{a});
                    eventTypeTags.put(types, combinedTags);
                end
            end
        end % extractcsvetypetags
        
        function eventTags = extracteventtags(event)
            eventTags = java.util.HashMap;
            if isfield(event, 'usertags') || isfield(event, 'hedtags')
                for a = 1: length(event)
                    userTags = {};
                    hedTags = {};
                    if isfield(event, 'usertags') && ...
                            ~isempty(event(a).usertags)
                        userTags = strsplit(event(a).usertags, ',');
                    end
                    if isfield(event, 'hedtags') && ...
                            ~isempty(event(a).hedtags)
                        hedTags = strsplit(event(a).hedtags, ',');
                    end
                    eventTags.put(int64(a), union(userTags, hedTags));
                end
            end
        end % extractEventTags
        
        function typeTagMaps = extracttypetagmaps(fieldMaps)
            % Extracts the type tagMap
            typeTagMaps = struct('field', [], 'values', []);
            numFieldMaps = length(fieldMaps);
            b = 1;
            for a = 1:numFieldMaps
                eventFields = {fieldMaps(a).map.field};
                if any(strcmpi('type', eventFields))
                    typeIndecie = strcmpi('type', eventFields);
                    typeTagMaps(b) = fieldMaps(a).map(typeIndecie);
                    b = b + 1;
                end
            end
        end % extracttypetagmaps
        
        function typeHashMap = extracteventtypetags(uniqueTypes, ...
                typeTagMaps)
            typeHashMap = DbHandler.initializetypehashmap(uniqueTypes);
            numTypeTagMaps = length(typeTagMaps);
            numUniqueTypes = length(uniqueTypes);
            for a = 1:numTypeTagMaps
                tagMapTypes = {typeTagMaps(a).values.label};
                tagMapTags = {typeTagMaps(a).values.tags};
                for b = 1:numUniqueTypes
                    typeIndice = strcmpi(uniqueTypes{b}, tagMapTypes);
                    if any(typeIndice)
                        typeTags = tagMapTags(typeIndice);
                        typeHashMapTags = typeHashMap.get(uniqueTypes{b});
                        if isempty(typeTags{1})
                            continue;
                        elseif iscellstr(typeTags{1})
                            typeTags = typeTags{1};
                        end
                        if ~isempty(typeHashMapTags)
                            typeHashMapTags = cell(typeHashMapTags);
                        end
                        combinedTags = union(typeTags, typeHashMapTags);
                        typeHashMap.put(uniqueTypes{b}, combinedTags);
                    end
                end
            end
        end % extracteventtypetags
        
        function typeHashMap = initializetypehashmap(uniqueTypes)
            typeHashMap = java.util.HashMap;
            numUniqueTypes = length(uniqueTypes);
            for a = 1:numUniqueTypes
                typeHashMap.put(uniqueTypes{a}, {});
            end
        end % initializetypehashmap
        
        function [values, doubleValues, range] = ...
                extractvalues(structure, doubleColumns, isInsert)
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
        
        function storezipfile(DB, entityUuid, filenames, ...
                isAdditionalData)
            zipFileName = [tempname '.zip'];
            zip(zipFileName,filenames);
            edu.utsa.mobbed.Datadefs.storeBlob(DB.getconnection(), ...
                zipFileName, entityUuid, isAdditionalData);
            delete(zipFileName);
        end % storezipfile
        
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

