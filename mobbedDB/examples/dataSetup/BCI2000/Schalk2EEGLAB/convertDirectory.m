%% script to convert recursively all Schalk's edf files to the EEGLAB set files 
%  in the directory and its sub directories
%  . by Kyung, Dec 8, 2012
%
%  edf: schalk's BCI dataset
%  set: EEGLAB dataset
%
%  how to use: run and select the top directory
%
%  requirement: None
%
function convertDirectory
    dirName = uigetdir;
    schalk2set_directory(dirName);
    fprintf('Done.\n');
end

function schalk2set_directory(dirName) 
    listing = dir(dirName);      
    for l=1:length(listing)
        if listing(l).isdir     % if directory, process it recursively
            switch listing(l).name
                case '.'
                case '..'
                otherwise
                    schalk2set_directory(fullfile(dirName, listing(l).name));
            end
        else
            schalk2set(fullfile(dirName, listing(l).name));
        end
    end
end

