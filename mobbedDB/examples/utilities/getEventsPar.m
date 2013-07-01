% getEventsPar   wrapper that allows retrieval of events by worker threads
function [eventTypes, eventCounts, tElapsed] = getEventsPar(dbName, ...
    hostName,  userName, password, eventTypes)
tStart = tic;
eventCounts = {};
if ~isempty(eventTypes)
    DB = Mobbed(dbName, hostName, userName, password, false);
    [eventTypes, eventCounts] = getEvents(DB, eventTypes);
    close(DB);
end
tElapsed = toc(tStart);
end % getEventsPar