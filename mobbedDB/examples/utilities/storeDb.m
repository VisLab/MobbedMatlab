% storeDB      store a list of files to a database
%
% Parameters:
%    DB           Mobbed object representing an open database connection
%    fPaths       cell array containing full paths of .mat files to store
%    namePrefix   name prefix of datasets to be written
%    uniqueEvents cell array of UUIDs of previously defined events
%    fUUIDs       (output) cell array of UUIDs of datasets stored
%    uniqueEvents (output) cell array of UUIDs of unique events
%

function [fUUIDs, uniqueEvents, tElapsed] = storedb(DB, fPaths, ...
                             modality, nameSpace, namePrefix, uniqueEvents)

    tStart = tic;
    z = getdb(DB, 'modalities', 0);  % Set modality
    z.modality_name = modality;
    newZ = getdb(DB, 'modalities', inf, z);
    dataTemplate = DB.getdb('datasets', 0);
    dataTemplate.dataset_namespace = nameSpace;
    dataTemplate.dataset_modality_uuid = newZ(1).modality_uuid;
    fileRegExp = ['[^\' filesep ']+$'];
    fileNames = regexp(fPaths, fileRegExp, 'match');
    fUUIDs = cell(length(fPaths), 1);
    for k = 1:length(fPaths)   
        x = load(fPaths{k});
        fNames = fieldnames(x);
        fileName = fileNames{k};
        temp = dataTemplate; 
        if isempty(fileNames{k})
            warning('storeFiles:emptyName', ...
                'File %g (%s) has an empty file name and can''t be stored', ...
                k, fPaths{k});
            continue;
        end
        temp.dataset_name = [namePrefix ' ' fileName{1}];
        temp.dataset_description = [namePrefix ' ' fPaths{k}];
        temp.data = x.(fNames{1});
        [fUUIDs{k}, uniqueEvents] =  mat2db(DB, temp, 'eventTypes', uniqueEvents);
    end
    tElapsed = toc(tStart);
end % storeDb
