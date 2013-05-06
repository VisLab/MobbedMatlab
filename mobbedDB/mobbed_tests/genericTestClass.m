classdef genericTestClass < hgsetget
    % Create a GENERIC data structure for testing MobbedDB
    %
    % Inputs:
    %    numElements = number of elements to create
    properties (Access = public)
        data
    end % public properties
    
    methods (Access = public)
        function obj = genericTestClass(numElements, numEvents, ...
                numMeta, numExtra)
            if numElements > 0
                obj.setElements(numElements, numExtra);
            end
            if numEvents > 0
                obj.setEvents(numEvents, numExtra);
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
