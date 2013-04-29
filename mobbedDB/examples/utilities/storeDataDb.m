% storeDataDb store a list of files to a database and stores exploded data
%
% Parameters:
%    DB           Mobbed object representing an open database connection
%    fPaths       cell array containing full paths of files to store
%    fieldName    string specifying the structure
%    dataType
%
%  Files must be readable by MATLAB load and contain
%
%  TODO:  This function needs to be generalized.
function [fUUIDs, tElapsed] = storedatadb(DB, fPaths, modality, dataType, uniqueEvents)

tStart = tic;

z = getdb(DB, 'modalities', 0);  % Set modality
z.modality_name = modality;
newZ = getdb(DB, 'modalities', inf, z);
dataTemplate = DB.getdb('datasets', 0);
dataTemplate.dataset_namespace = 'edu.utsa.cs';
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
    temp.dataset_name = fileName{1};
    temp.dataset_description = [fPaths{k}];
    temp.data = x.(fNames{1});
    [fUUIDs(k), uniqueEvents] = ...
        mat2db(DB, temp, 'eventTypes', uniqueEvents);
    sdef = getdb(DB, 'datadefs', 0);     % set the data definition template
    sdef.datadef_format = dataType;
    sdef.datadef_sampling_rate = x.(fNames{1}).srate;
    sdef.data = x.(fNames{1}).data;
    sdef.datadef_description = [x.(fNames{1}).setname ' ' x.(fNames{1}).filename ' individual frames'];
    sdefUUID = data2db(DB, sdef);
    smap = getdb(DB, 'datamaps', 0);
    smap.datamap_def_uuid = sdefUUID{1};
    smap.datamap_path = '/EEG/dataEx'; % where to put on retrieval
    smap.datamap_entity_uuid = fUUIDs{k};
    putdb(DB, 'datamaps', smap);
end
commit(DB);
tElapsed = toc(tStart);
end
