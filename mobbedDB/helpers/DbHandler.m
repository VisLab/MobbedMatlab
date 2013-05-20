classdef DbHandler
    
    methods(Static)
        
        function addJavaPath()
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
        end % addJavaPath
        
        function [mName, mUUID] = checkModality(DB, modalityUUID)
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
        end % checkModality
        
        function jArray = createJaggedArray(array)
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
        end % createJaggedArray
        
        function [values, doubleValues] = extractValues(structure, ...
                doubleColumns)
            % extracts values from a structure array
            numStructs = length(structure);
            numColumns = length(doubleColumns);
            if numColumns < 1
                doubleValues = [];
            else
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
                squeeze(struct2cell(structure))', 'UniformOutput', false);
        end % extractValues
        
        function string = reformatString(string)
            % Convert character string to cellstr
            if ischar(string), string = cellstr(string); end;
        end % reformatString
        
        function value = replaceEmpty(a, b)
            % Return a if non-empty otherwise return b
            if isempty(a)
                value = b;
            else
                value = a;
            end
        end % replaceEmpty
        
        function data = retrieveDataDef(DB, datadefUuid, datadefFormat, ...
                additionalData)
            % Retrieves the data associated with a datadef
            if strcmpi(datadefFormat, 'EXTERNAL')
                data = DbHandler.retrieveFile(DB, datadefUuid, ...
                    additionalData);
            elseif strcmpi(datadefFormat, 'NUMERIC_STREAM')
                data = DbHandler.retrieveNumericStream(DB, datadefUuid);
            elseif strcmpi(datadefFormat, 'NUMERIC_VALUE')
                data = double(...
                    edu.utsa.mobbed.Datadefs.retrieveNumericValue(...
                    DB.getConnection(), datadefUuid));
            elseif strcmpi(datadefFormat, 'XML_VALUE')
                data = char(edu.utsa.mobbed.Datadefs.retrieveXMLValue(...
                    DB.getConnection(), datadefUuid));
            else throw(MException('retrieveDataDef:InvalidFormat', ...
                    'Datadef format is invalid'));
            end
        end % retrieveDataDef
        
        function file = retrieveFile(DB, entityUUID, isAdditionalData)
            % Retrieves data from a external file
            fileName = [tempname '.mat'];
            edu.utsa.mobbed.Datadefs.retrieveBlob(DB.getConnection(), ...
                fileName, entityUUID, isAdditionalData);
            if exist(fileName, 'file')
                load(fileName);
                file = data;
                delete(fileName);
            else
                file = [];
            end
        end % retrieveExternal
        
        function data = retrieveNumericStream(DB, data_def_uuid)
            % Retrieves numeric stream from database
            jNumericData = ...
                edu.utsa.mobbed.NumericStreams(DB.getConnection());
            jNumericData.reset(data_def_uuid);
            numElements = ...
                edu.utsa.mobbed.NumericStreams.getArrayLength(...
                DB.getConnection(), data_def_uuid);
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
        end % retrieveNumericStream
        
        function storeFile(DB, entityUuid, data, ...
                isAdditionalData) %#ok<INUSL>
            % Store data in a external file
            fileName = [tempname '.mat'];
            save(fileName, 'data', '-v7.3');
            edu.utsa.mobbed.Datadefs.storeBlob(DB.getConnection(), ...
                fileName, entityUuid, isAdditionalData);
            delete(fileName);
        end % storeExternal
        
        function storeDataDef(DB, datadefUuid, datadef)
            % Stores data associated with a datadef
            if strcmpi(datadef.datadef_format, 'EXTERNAL')
                DbHandler.storeFile(DB, datadefUuid, datadef.data, false)
            elseif strcmpi(datadef.datadef_format, 'NUMERIC_STREAM')
                if ~isfield(datadef, 'datadef_sampling_rate') && ...
                        ~isfield(datadef, 'datadef_timestamps')
                    throw (MException(['storeDataDef:' ...
                        'InvalidSamplingRate'], ...
                        'sample rate and timestamps are not present'));
                end
                if  isfield(datadef, 'datadef_sampling_rate')
                    if datadef.datadef_sampling_rate < 0
                        datadef.datadef_sampling_rate = 1;
                    end
                    times = zeros(1,size(datadef.data,2));
                    for a = 2:length(times)
                        times(a) = (a-1)/datadef.datadef_sampling_rate;
                    end
                else
                    times = datadef.timestamps;
                end
                DbHandler.storeNumericStream(DB, datadefUuid, ...
                    datadef.data, times);
            elseif strcmpi(datadef.datadef_format, 'NUMERIC_VALUE')
                edu.utsa.mobbed.Datadefs.storeNumericValue(...
                    DB.getConnection(), datadefUuid, datadef.data);
            elseif strcmpi(datadef.datadef_format, 'XML_VALUE')
                edu.utsa.mobbed.Datadefs.storeXMLValue(...
                    DB.getConnection(), datadefUuid, datadef.data);
            else throw (MException('retrieveDataDef:InvalidFormat', ...
                    'Datadef format is invalid'));
            end
        end % storeDataDef
        
        function storeNumericStream(DB, dataDefUuid, data, times)
            % Stores numeric stream
            numFrames = length(data);
            jNumericStream = edu.utsa.mobbed.NumericStreams(...
                DB.getConnection());
            jNumericStream.reset(dataDefUuid);
            k = 1;
            while(k < numFrames)
                eIndex = min(k + 10000 - 1, numFrames);
                signals = double(data(:, k:eIndex));
                signalTimes = times(k:eIndex);
                jNumericStream.save(signals, signalTimes, int64(k));
                k = k + 10000;
            end
        end % storeNumericStream
        
        function success = validateUUIDs(UUIDs)
            % Validates a cellstr of UUIDs
            if isempty(UUIDs), success = true; return; end;
            UUIDs = DbHandler.reformatString(UUIDs);
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
        end % validateUUID
        
    end % static methods
    
end

