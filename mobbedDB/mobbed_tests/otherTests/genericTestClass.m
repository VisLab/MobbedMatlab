classdef genericTestClass < hgsetget
    % Create a GENERIC data structure for testing MobbedDB
    %
    % Inputs:
    %    numElements = number of elements to create
    properties (Access = public)
        data
        featureTypes = {'numeric', 'numeric_stream', 'xml', 'xml_stream'};
    end % public properties
    
    
    methods (Access = public)
        function obj = genericTestClass(numElements, numEvents, ...
                featureType, numMeta, numExtra)
            if numElements > 0
                obj.setElements(numElements, numExtra);
            end
            if numEvents > 0
                obj.setEvents(numEvents, numExtra);
            end
            if any(strcmpi(featureType, obj.featureTypes))
                obj.setFeatures(featureType, numElements, numExtra);
            end
            if numMeta > 0
                obj.setMetadata(numMeta);
            end
        end % TestClass constructor
        
        function setElements(obj, numElements, numExtra)
            % Set the element substructure
            positions = (1:numElements)';
            labels = strcat({'E'}, strtrim(cellstr(num2str(positions))));
            descriptions = strcat({'element: '}, labels);
            element = struct('label', labels, 'position', labels, ...
                'description', descriptions);
            
            for j = 1:length(element)
                element(j).position = positions(j);
                for k = 1:numExtra
                    thisName = ['extra' num2str(k)];
                    element(j).(thisName) = [thisName ': ' labels{j}];
                end
            end
            obj.data.element = element;
        end % setElements
        
        function setEvents(obj, numEvents, numExtra)
            % Set the event substructure
            positions = (1:numEvents)';
            types = strcat({'EV'}, strtrim(cellstr(num2str(positions))));
            event = struct('type', types, 'position', types, ...
                'stime', types, 'etime', types, 'certainty', types);
            
            for j = 1:length(event)
                event(j).position = int64(positions(j));
                event(j).stime = int64(positions(j)*3);
                event(j).etime = int64(positions(j)*3);
                event(j).certainty = rand(1,1);
                for k = 1:numExtra
                    thisName = ['extra' num2str(k)];
                    event(j).(thisName) = [thisName ': ' types{j}];
                end
            end
            obj.data.event = event;
        end % setElements
        
        function setFeatures(obj, featureType, numElements, numExtra)
            feature.type = featureType;
            feature.description = 'feature description';
            if strcmpi(featureType, 'numeric_stream')
                % create 2-d matrix from sample eeg data 
                load('EEG.mat');
                feature.value.data = EEG.data(1:numElements, :);
                feature.value.samplingrate = EEG.srate;
            end
            if strcmpi(featureType, 'numeric')
                % create 1-d vector from sample eeg data 
                load('EEG.mat');
                feature.value = EEG.data(1, :);
            end
            if strcmpi(featureType, 'xml')
                % read from sample.xml file 
                feature.value = xmlwrite(which('sample.xml'));
                feature.value = strrep(feature.value, ...
                    '<?xml version="1.0" encoding="utf-8"?>', '');
            end
            for k = 1:numExtra
                thisName = ['extra' num2str(k)];
                feature.(thisName) = [thisName ': ' feature.type];
            end
            obj.data.feature = feature;
        end
        
        function setMetadata(obj, numMeta)
            % Set the metadata structure
            metadata = struct();
            for k = 1:numMeta
                thisName = ['meta' num2str(k)];
                metadata.(thisName) = [thisName ': data'];
            end
            obj.data.metadata = metadata;
        end % setMetadata
    end % public methods
    
    
end % ModelSettingsTestClass
