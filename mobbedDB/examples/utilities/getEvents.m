% getEvents   retrieve events of specified types from database
function [eventTypes, eventCounts, tElapsed] = getEvents(DB, eventTypes)
tStart = tic;
sEvents = getdb(DB, 'events', 0);
eventCounts = cell(length(eventTypes), 1);
for k = 1:length(eventTypes)
    sEvents.event_type_uuid = eventTypes{k};
    events = getdb(DB, 'events', inf, sEvents);
    eventCounts{k} = length(events);
    % Do something with the events here
end
tElapsed = toc(tStart);
end % getEvents