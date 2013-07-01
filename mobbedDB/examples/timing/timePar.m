% timePar    time database operations for a set of datasets
%
% Usage:
%  >> timeParallel(dbName, hostName, userName, password, dbScript, ...
%                  inDir, nameSpace, dataName, modality, threads)
%
% Input
%    dbName     name of database to be created (must not exist)
%    hostName


function timePar(dbName, hostName, userName, password, dbScript, ...
    inDir, nameSpace, dataName, modality, threads)

fprintf('Timing script %s with %g threads...\n', dbName, threads);


%% Get the pathnames of files in the inDir directory tree
fprintf('Creating a list of files for %s tree...\n', inDir);
[fPaths, tElapsed] = getFileList(inDir);
fprintf('\tTotal files: %g took %g s (%g s average)\n', length(fPaths), ...
    tElapsed, tElapsed/length(fPaths));

%% Loading datasets and storing in temporary file
fprintf('Loading and storing %g files to temporary file system...\n', ...
    length(fPaths));
tStart = tic;
% Parcel out the work
if isempty(threads) || threads < 2
    workers = 1;
else
    workers = threads;
end
indexFiles = mod((1:length(fPaths))' - 1, workers) + 1;
fPathGroups = cell(workers, 1);
for k = 1:workers
    fPathGroups{k} = fPaths(indexFiles == k);
end
tElapsedFiles = zeros(workers, 1);
% Do the workers
if isempty(threads) || threads == 0
    for k = 1:workers
        [~, tElapsedFiles(k)] = storeTemp(fPathGroups{k}) ;
    end
else
    parfor k = 1:workers
        [~, tElapsedFiles(k)] = storeTemp(fPathGroups{k}) ;
    end
end
tElapsed = toc(tStart);
fprintf(['\tLoaded, saved, and deleted %g datasets from local file' ...
    ' system in %g s (%g s average)\n'], ...
    length(fPaths), tElapsed, tElapsed/length(fPaths));
fprintf('\tWorker times:\n')
for k = 1:workers
    fprintf('\t\t%g datasets in %g s\n', length(fPathGroups{k}), ...
        tElapsedFiles(k));
end
%% Create the database
fprintf('Creating database %s\n', dbName);
tStart = tic;
try
    Mobbed.createdb(dbName, hostName, userName, password, dbScript, false)
catch ME   % If database already exists, creation fails and warns
    warning('mobbed:creationFailed', ME.message);
end
tElapsed = toc(tStart);
fprintf('\tCreated database %s in %g s\n', dbName, tElapsed);

%% Load the datasets and create unique events in the database
fprintf('Creating unique event types and attributes in %s...\n', dbName);
tStart = tic;
uniqueTypes = {};
uniqueEventAttributes = {};
for k = 1:length(fPaths)
    load(fPaths{k});
    eTypes = {EEG.event.type}';
    uniqueTypes = union(uniqueTypes, eTypes);
    uniqueEventAttributes = union(uniqueEventAttributes, ...
        fieldnames(EEG.event));
end
DB = Mobbed(dbName, hostName, userName, password, false);
% Insert unique event types in database
typeTemplate(length(uniqueTypes)) = getdb(DB, 'event_types', 0);
for k = 1:length(uniqueTypes)
    typeTemplate(k).event_type = num2str(uniqueTypes{k});
    typeTemplate(k).event_type_description = ...
        [dataName typeTemplate.event_type];
end
uniqueEvents = putdb(DB, 'event_types', typeTemplate);
% Insert event attribute types in database  ---- must do this
tElapsed = toc(tStart);
fprintf(['\tCreated %g unique events and %g unique event attributes in' ...
    ' %g s\n'], ...
    length(uniqueEvents), length(uniqueEventAttributes), tElapsed);
close(DB);

%% Store the datasets in the database
fprintf('Storing %g datasets in the database %s...\n', length(fPaths), ...
    dbName);
tStart = tic;
fUUIDsThread = cell(workers, 1);
uniqueEventsThread = cell(workers, 1);
tElapsedStore = zeros(workers, 1);
% Do the workers
if isempty(threads) || threads == 0
    for k = 1:workers
        [fUUIDsThread{k}, uniqueEventsThread{k}, tElapsedStore(k)] = ...
            storeDbPar(dbName, hostName, userName, password, ...
            fPathGroups{k}, modality, nameSpace, dataName, uniqueEvents);
    end
else
    parfor k = 1:workers
        [fUUIDsThread{k}, uniqueEventsThread{k}, tElapsedStore(k)] = ...
            storeDbPar(dbName, hostName, userName, password, ...
            fPathGroups{k}, modality, nameSpace, dataName, ...
            uniqueEvents);  %#ok<PFOUS>
    end
end
tElapsed = toc(tStart);
fprintf(['\tStored the %g datasets in the database in %g s' ...
    ' (%g s average)\n'], ...
    length(fPaths), tElapsed, tElapsed/length(fPaths));
fprintf('\tStore worker times:\n')
for k = 1:workers
    fprintf('\t\t%g datasets in %g s\n', length(fUUIDsThread{k}), ...
        tElapsedStore(k));
end
fprintf('\n');
input('Press enter to continue after maintenance', 's');

%% Retrieve the datasets
fprintf('Retrieving data from %s...\n', dbName);
tElapsedLoad = zeros(workers, 1);
fUUIDGroups = cell(workers, 1);
tStart = tic;
parfor k = 1:workers
    [fUUIDGroups{k}, tElapsedLoad(k)] = loadDbPar(dbName, hostName,  ...
        userName, password, fUUIDsThread{k});
end
tElapsed = toc(tStart);
fprintf('\tLoaded the data from the database in %g s (%g s average)\n', ...
    tElapsed, tElapsed/length(fPaths));
fprintf('\tWorker times:\n')
for k = 1:workers
    fprintf('\t\t%g datasets in %g s\n', length(fUUIDGroups{k}), ...
        tElapsedLoad(k));
end
fprintf('\n');

%% Retrieve events of a certain type from db
fprintf('Retrieving events from db by type %s ...\n', dbName);
tStart = tic;
index = mod((1:length(uniqueEvents))' - 1, workers) + 1;
eventCounts = cell(workers, 1);
eventTypes = cell(workers, 1);
tElapsedEvents = zeros(workers, 1);
eventGroups = cell(workers, 1);
for k = 1:workers;
    eventGroups{k} = uniqueEvents(index == k);
end;
for k = 1:workers
    [eventTypes{k}, eventCounts{k}, tElapsedEvents(k)] = ...
        getEventsPar(dbName, hostName,  ...
        userName, password, eventGroups{k});
end
tElapsed = toc(tStart);
totalEvents = 0;
for k = 1:workers
    thisCount = eventCounts{k};
    if ~isempty(thisCount) && iscell(thisCount)
        thisType = eventTypes{k};
        for j = 1:length(thisCount)
            fprintf('Event %s: %g\n', thisType{j}, thisCount{j});
            totalEvents = totalEvents + thisCount{j};
        end
    end
end
fprintf('\tRetrieved %g events of %s from %s:\n', totalEvents, ...
    dataName, dbName);
fprintf(['\tTotal time: %g s, average time per dataset: %g s' ...
    ' (%g s per event)\n'], ...
    tElapsed, tElapsed/length(fPaths), tElapsed/totalEvents);

%% Store exploded data in the database
fprintf(['Storing exploded data from %g datasets in the database' ...
    ' %s...\n'], length(fPaths), dbName);
tStart = tic;
fUUIDsData = cell(workers, 1);
tElapsedStoreData = zeros(workers, 1);
% Do the workers
if isempty(threads) || threads == 0
    for k = 1:workers
        [fUUIDsData{k}, tElapsedStore(k)] = ...
            storeDataDbPar(dbName, hostName, userName, password, ...
            fPathGroups{k}, modality, 'NUMERIC_STREAM', uniqueEvents);
    end
else
    parfor k = 1:workers
        [fUUIDsData{k}, tElapsedStoreData(k)] = ...
            storeDataDbPar(dbName, hostName, userName, password, ...
            fPathGroups{k}, modality, 'NUMERIC_STREAM', uniqueEvents);
    end
end
tElapsed = toc(tStart);
fprintf(['\tStored exploded data from %g datasets in the database in' ...
    ' %g s (%g s average)\n'], ...
    length(fPaths), tElapsed, tElapsed/length(fPaths));
fprintf('\tStore data worker times:\n')
for k = 1:workers
    fprintf('\t\t%g datasets in %g s\n', length(fUUIDsData{k}), ...
        tElapsedStoreData(k));
end
fprintf('\n');
input('Press enter to continue after maintenance', 's');
%% Retrieve the exploded data
fprintf('Retrieving exploded data from %s...\n', dbName);
tElapsedLoadData = zeros(workers, 1);
tStart = tic;
parfor k = 1:workers
    [fUUIDsData{k}, tElapsedLoadData(k)] = loadDataDbPar(dbName, ...
        hostName,  userName, password, fUUIDsData{k});
end
tElapsed = toc(tStart);
fprintf(['\tLoaded the exploded data from the database in %g s' ...
    ' (%g s average)\n'], ...
    tElapsed, tElapsed/length(fPaths));
fprintf('\tWorker times:\n')
for k = 1:workers
    fprintf('\t\t%g datasets in %g s\n', length(fUUIDsData{k}), ...
        tElapsedLoadData(k));
end
fprintf('\n');
