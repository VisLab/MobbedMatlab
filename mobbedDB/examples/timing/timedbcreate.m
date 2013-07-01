function tElapsed = timeDbCreate(dbNames, hostName, userName, password, ...
    dbScript)
% Create the specified number of databases and return the time elapsed
%
% Parameters
%   dbNames  cell array of strings with database names
%            (converted to lowercase)
%   hostName string with URL of host or 'localhost' for local machine
%   userName string with user name
%   password string containing password
%   dbScript .xml or .sql file containing commands to create database
%   tElapsed (output) time in seconds to perform the creation
%
% Note: verbose is turned off to improve timing accuracy

%% Create databases if they don't doesn't exist
tStart = tic;
for k = 1:length(dbNames)
    try
        Mobbed.createdb(dbNames{k}, hostName, userName, password, ...
            dbScript, false)
    catch ME   % If database already exists, creation fails and warns
        warning('mobbed:creationFailed', ME.message);
    end
end
tElapsed = toc(tStart);
