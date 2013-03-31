%% mat2Db
% Mobbed method to create a dataset in the database 

%% Syntax
%     s = mat2DB(DB)
%     [sUUIDs, uniqueEvents] = mat2DB(DB, datasets)
%     [sUUIDs, uniqueEvents] = mat2DB(DB, datasets, isUnique)
%     [sUUIDs, uniqueEvents] = mat2DB(..., 'Name1', 'Value1', ...)
%
%% Description
%
% |mat2DB(DB)| returns an empty structure for the user to fill in the
% information needed to store a dataset.  The fields
% visualization. The |event| parameter is a structure array with three
% fields: |type|, |time|, and |certainty|. The |type| is a string or
% numerical value indicating the event type. The |time| is a double
% representing the time in seconds at which the event occurred. The
% |certainty| is a value between 0 and 1 indicating how certain the event
% is. Generally, externally recorded events will have a certainty of 1.
% However, events may also be computed from signal features. In this
% case the certainty value may be assigned from probabilities derived
% from an algorithm.
%
% The visualization is assumed to be divided into (potentially
% overlapping) fixed length blocks that are used for summaries.
%
% |viscore.blockedEvents(event, 'Name1', 'Value1', ...)| specifies 
% optional name/value parameter pairs:
%
% <html>
% <table>
% <thead><tr><td>Name</td><td>Value</td></tr></thead>
% <tr><td><tt>'BlockStartTimes'</tt></td>
%      <td>optional vector of start times (in seconds) of blocks</td></tr>
% <tr><td><tt>'BlockTime'</tt></td>
%      <td>length of block in seconds</td></tr>
% <tr><td><tt>'MaxTime'</tt></td>
%      <td>maximum time in seconds to use</td></tr>
% </table>
% </html>
%
%
% |obj = viscore.blockedEvents(...)| returns a handle to the newly created
% object.
%
% The event order is alphabetical by default. The order is relevant for
% the order in which events occur in the visualization. 
%
% In a future implementation an EventOrder parameter will be provided
% that allows users to over-ride this behavior by specifying the
% types of events that should appear first (and hence are displayed more
% prominently). Any event types not mentioned would not be not displayed.
%

%% Example 1
% Create a blocked events object for an EEGLAB EEG structure
   load('EEG.mat');
   blockTime = 1000/128;
   eventTimes = (round(double(cell2mat({EEG.event.latency}))') - 1)./EEG.srate;
   events = struct('type', {EEG.event.type}', 'time', num2cell(eventTimes), ...
                   'certainty', ones(length(eventTimes), 1));
   ed2 = viscore.blockedEvents(events, 'BlockTime', blockTime);

%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |viscore.blockedEvents|:
%
%    doc viscore.blockedEvents
%
%% See also
% <blockedData_help.html |viscore.blockedData|>, 
% <eventImagePlot_help.html |visviews.eventImagePlot|>, and
% <eventStackedPlot_help.html |visviews.eventStackedPlot|>
%
%% 
% Copyright 2012 Kay A. Robbins, University of Texas at San Antonio