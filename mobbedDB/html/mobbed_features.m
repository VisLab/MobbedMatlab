%% EEGVIS Package Features
%
%% What is "EEGVIS"?
% EEGVIS is an extensible MATLAB toolkit that you can incorporate into 
% their normal workflow to examine large scale array datasets and quickly 
% assess the effects of various operations at different stages in your
% processing pipelines. 
% 
% Although the EEGVIS toolkit was motivated by large-scale EEG data sets,
% It can be used with any type of array data. You can create specialized
% visualizations for any purpose.


%% How can you use the EEGVIS toolkit?
%
% * Call |eegvis| to create a visualization of array data from the command
% line or in one of your scripts or functions
% * Use |eegbrowse| to quickly examine a large group of EEG data sets
% * Use the eegvis toolkit plugins for EEGLAB to browse or visualize
% EEG data directly.
% * Use |visviews.dualView| directly to create specialized visualizations
% for any type of array data.
% * Develop your own visualization panels by extending |visviews| base
% classes.
% * Call |eegvis| and |eegbrowse| as a standalone program without MATALB.
%
%% EEGVIS visualizations are cursor explorable
% 
% The figure windows created by |eegvis| and |visviews.dualView| allow
% pan, zoom, and the data cursor. In addition, by entering cursor
% exploration mode, you can sweep the cursor over the entire figure
% window and get a continuous read out of the underlying values. This
% is very useful for quickly exploring the data set.
%
%% EEGVIS visualizations are clickable and linkable
%
% The EEGVIS toolkit uses a flexible heirarchical drill down strategy to enable
% exploration of very large data sets. A summary function such as kurtosis
% or standard deviation is computed on windows of data (e.g., 1000 time
% samples). The block values are themselves grouped and summarized to
% provide a more compact summary. You can then click on the summary to
% view the next level of details down.
%
% You can create drill-down hierarchies of arbitrary level just by 
% entering text in a table. By creating additional levels in the view
% hierarchy, you can visualize and quickly browse huge data sets.
%
%% EEGVIS visualizations are attractively resizable
%
% One inherent difficulty with building visualizations in MATLAB is the
% lack of layout managers and resizing capability. The eegvis toolkit
% is built using the |+uextras| package from members of the MATHWORKS
% team (<http://www.mathworks.com/matlabcentral/fileexchange/27758 GUI
% Layout Toolbox>). This toolbox provides a tab panel and vertical
% and horizontal grids with draggable dividers that allow you to
% change the area each component occupies in the view. This is key
% to effective exploration.
%
%% EEGVIS components are configurable
%
% You can configure the following items through convenient GUIs:
%
% * Which visualization panels to show in your figure and how to link
% them for clicking and drill-down.
% * How many and which summary functions to use.
% * The configurable public properties of the individual visualizations
%
% eegvis configurations can be saved and loaded so you can create
% specialized configurations for different purposes.
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio
% 
