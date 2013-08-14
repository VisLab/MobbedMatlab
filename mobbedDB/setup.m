%% Setup the MATLAB and java paths needed to run.
% You must have already installed postgreSQL 9.2 or later
% If you want to read EEGLAB .set files, you will also need to add
% EEGLAB and its subdirectories to the path.
%
%% Add the appropriate paths
    configPath = fileparts(which('Mobbed'));
    addpath(genpath(configPath));
    DbHandler.addjavapath();