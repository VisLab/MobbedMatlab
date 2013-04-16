%% mat2Db
% Mobbed method to create a dataset in the database 

%% Syntax
%     s = mat2db(DB)
%     [sUUIDs, uniqueEvents] = mat2db(DB, datasets)
%     [sUUIDs, uniqueEvents] = mat2db(DB, datasets, isUnique)
%     [sUUIDs, uniqueEvents] = mat2db(..., 'Name1', 'Value1', ...)
%
%% Description
%
% |mat2db(DB, datasets)| stores 
%
%
% <html>
% <table>
% <thead><tr><td>Name</td><td>Value</td></tr></thead>
% <tr><td><tt>'EventTypes'</tt></td>
%      <td>A cell array of UUIDs of the event types associated with this dataset.</td></tr>
% <tr><td><tt>'Tags'</tt></td>
%      <td>A string or a cell array of strings specifying the 
%      tags to be associated with the datasets stored in this operation. </td></tr>
% </table>
% </html>
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