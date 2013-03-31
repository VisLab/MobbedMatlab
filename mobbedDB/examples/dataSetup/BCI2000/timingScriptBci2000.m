%% Set up parameters for timing
hostName = 'localhost';
dbName = 'bci2000db';
inDir = 'H:\BCIProcessing\BCI2000Mat';
dataName = 'BCI2000';
modality = 'eeg';
tagFunction = @getTagsBci2000;

%% Get a list of files
fPaths = getFileList(inDir);
for k = 1:length(fPaths)
    fprintf('%s\n', fPaths{k});
end
fprintf('Total files: %g\n', length(fPaths));

%% Create database if it doesn't exist
fprintf('Creating a dataase for unexploded data ...\n');
tStart = tic;
try
    Mobbed.createdb(dbName, hostName, 'postgres', 'admin', 'mobbed.xml', false)
catch ME   % If database already exists, creation fails and warns
    warning('mobbed:creationFailed', ME.message);
end
tElapsed = toc(tStart);
fprintf('Creating database %s: %g s\n', dbName, tElapsed);

%% Open a connection to the database
DB = Mobbed(dbName, hostName, 'postgres', 'admin', false);

%% Store data in the database (untagged and unexploded)
fprintf('Storing data untagged and unexploded ...\n');
tStart = tic;
[fUUIDs, uniqueEvents] = storeDb(DB, inDir, modality, dataName, true);
tElapsed = toc(tStart);
fprintf('Storing %g files from %s in %s:\n', length(fUUIDs), dataName, dbName);
fprintf('   Total time: %g s, average time: %g s\n', ...
            tElapsed, tElapsed/length(fUUIDs));
fprintf('   Number of unique events: %g\n', length(uniqueEvents));

%% Vacuum the result (and wait)
fprintf('Vacuuming the database\n');
vacuum(DB);   % Ready the database for retrieval
pause(240);

%% Create a database for exploded data
fprintf('Creating a database for exploded data ...\n');
dbExplode = [dbName, 'ex'];
tStart = tic;
try
    Mobbed.createdb(dbExplode, hostName, 'postgres', 'admin', 'mobbed.xml', false)
catch ME   % If database already exists, creation fails and warns
    warning('mobbed:creationFailed', ME.message);
end
DBEX = Mobbed(dbExplode, hostName, 'postgres', 'admin', false);
tElapsed = toc(tStart);
fprintf('Creating database %s: %g s\n', dbExplode, tElapsed);


%% Store data in exploded form in a database
fprintf('Storing data in exploded form ...\n');
dataEx = [dataName 'EX'];
tStart = tic;
[fUUIDsEx, uniqueEventsEx] = storeDb(DBEX, inDir, modality, dataEx, false);
tElapsed = toc(tStart);
fprintf('Storing %g files from %s in %s:\n', length(fUUIDsEx), dataEx, dbExplode);
fprintf('   Total time: %g s, average time: %g s\n', ...
            tElapsed, tElapsed/length(fUUIDsEx));
fprintf('   Number of unique events: %g\n', length(uniqueEventsEx));

%% Vacuum the result (and wait)
fprintf('Vacuuming the database\n');
vacuum(DBEX);   % Ready the database for retrieval
pause(240);


%% Retrieve dataset (non exploded by UUID)
fprintf('Retrieving data from non-exploded db ...\n');
tStart = tic;
for k = 1:length(fUUIDs)
        dataset = db2mat(DB, fUUIDs{k}, false); 
end
tElapsed = toc(tStart);
fprintf('Retrieving %g datasets of %s from %s:\n', length(fUUIDs), dataName, dbName);
fprintf('   Total time: %g s, average time: %g s\n', ...
            tElapsed, tElapsed/length(fUUIDsEx));
fprintf('   Number of unique events: %g\n', length(uniqueEventsEx));

%% Retrieve dataset (exploded by UUID)
fprintf('Retrieving data from non-exploded db ...\n');
tStart = tic;
for k = 1:length(fUUIDsEx)
        dataset = db2mat(DBEX, fUUIDsEx{k}, true); 
end
tElapsed = toc(tStart);
fprintf('Retrieving %g datasets of %s from %s:\n', length(fUUIDsEx), dataEx, dbExplode);
fprintf('   Total time: %g s, average time: %g s\n', ...
            tElapsed, tElapsed/length(fUUIDsEx));
     
%% Retrieve events of a certain type from non-exploded db 
fprintf('Retrieving events from non-exploded db ...\n');
tStart = tic;
sEvents = getdb(DB, 'events', 0);
eventsByType = cell(length(uniqueEvents), 1);
for k = 1:length(uniqueEvents)
    sEvents.event_type_uuid = uniqueEvents{k};
    events = getdb(DB, 'events', inf, sEvents);
    eventsByType{k} = length(events);
end
tElapsed = toc(tStart);
fprintf('Retrieving events of %s from %s:\n', dataName, dbName);
fprintf('   Total time: %g s, average time: %g s\n', ...
            tElapsed, tElapsed/length(uniqueEvents));
totalEvents = 0;
for k = 1:length(uniqueEventsEx)
    fprintf('Event %s: %g\n', eventsByType{k});
    totalEvents = totalEvents + eventsByType{k};
end
fprintf('Total events retrieved: %g\n', totalEvents);        
%% Retrieve events of a certain type from exploded db 
fprintf('Retrieving events from exploded db ...\n');
tStart = tic;
sEvents = getdb(DBEX, 'events', 0);
eventsByTypeEx = cell(length(uniqueEvents), 1);
for k = 1:length(uniqueEventsEx)
    sEvents.event_type_uuid = uniqueEventsEx{k};
    events = getdb(DBEX, 'events', inf, sEvents);
    eventsByTypeEx{k} = length(events);
end
tElapsed = toc(tStart);
fprintf('Retrieving events of %s from %s:\n', dataEx, dbExplode);
fprintf('   Total time: %g s, average time: %g s\n', ...
            tElapsed, tElapsed/length(uniqueEvents));
totalEvents = 0;
for k = 1:length(uniqueEventsEx)
    fprintf('Event %s: %g\n', eventsByTypeEx{k});
    totalEvents = totalEvents + eventsByTypeEx{k};
end
fprintf('Total events retrieved: %g\n', totalEvents);