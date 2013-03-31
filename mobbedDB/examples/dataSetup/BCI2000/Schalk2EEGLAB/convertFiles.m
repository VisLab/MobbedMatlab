%% script to convert edf files to set files. by Kyung, Dec 8, 2012
%
%  edf: schalk's BCI dataset
%  set: EEGLAB dataset
%
%  how to use: run and select .edf files.
%              .set files will be saved in the same directory.
%
%  requirement: None
%
[FileList, PathName, ~] = uigetfile('*.edf', 'MultiSelect', 'on');
if iscell(FileList) == 1    % if multiple files are selected
    for i=1:length(FileList)
        schalk2set(fullfile(PathName, FileList{i}));
    end
else                        % if one file is selected
    schalk2set(fullfile(PathName, FileList));
end
fprintf('Done.\n');
