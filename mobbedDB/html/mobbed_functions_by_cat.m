%% Functions by category
% EEGVIS Visualization Package
% Version 1.0 11-Dec-2011
%
% Requires Statistics Toolbox.
%
%% Top-level functions
% * <eegbrowse_help.html |eegbrowse|> -  GUI for selecting .set files for visualization
% * <eegplugin_eegvis_help.html |eegplugin_eegvis|> -  makes eegbrowse and eegvis commands available from the EEGLAB menu
% * <eegvis_help.html |eegvis|> -  creates figure window with multi-level summary/details viewer 
% * <pop_eegbrowse_help.html |pop_eegbrowse|> -  opens a GUI for browsing EEGLAB
% * <pop_eegvis_help.html |pop_eegvis|> -  calls the eegvis command as a singleton callback for EEGLAB
%
%% Core package (+viscore)
% * <blockedData_help.html |blockedData|> - manages blocked data for visualization
% * <counter_help.html |counter|> - singleton class that returns a unique counter for IDS
% * <dataConfig_help.html |dataConfig|> - GUI base class for configuration
% * <dataManager_help.html |dataManager|> - enhanced map for managing configuration objects
% * <dataSelector_help.html |dataSelector|> - container that connects configuration GUI and managed objects
% * <dataSlice_help.html |dataSlice|> - defines a regular subarray for data manipulation
% * <managedObj_help.html |managedObj|> - base class for keyed configuration objects
% * <tableConfig_help.html |tableConfig|> - manages blocked data for visualization
% * <tablePanel_help.html |tablePanel|> - spreadsheet-like grid for editing values
%
%% Function package (+visfuncs)
% * <functionConfig_help.html |functionConfig|> - GUI for function configuration
% * <functionObj_help.html |functionObj|> - holds definition and current values of a summary function
%
%% Property package (+visprops)
% * <colorListProperty_help.html |colorListProperty|> - property object representing a list of colors
% * <colorProperty_help.html |colorProperty|> - property object representing a single color
% * <configurable_help.html |configurable|> - base class for objects with configurable properties
% * <configurableObj_help.html |configurableObj|> - component class for objects with configurable properties
% * <doubleProperty_help.html |doubleProperty|> - property object representing a double in a specified interval
% * <enumeratedProperty_help.html |enumeratedProperty|> - property object representing string from a list of strings
% * <integerProperty_help.html |integerProperty|> -  property object representing an integer in a specified interval
% * <intervalProperty_help.html |intervalProperty|> - property object representing a real interval
% * <logicalProperty_help.html |logicalProperty|>  -  property object representing a logical (boolean) value
% * <property_help.html |property|> - base class for configurable properties
% * <propertyConfig_help.html |propertyConfig|> - GUI for configuring properties
% * <stringListProperty_help.html |stringListProperty|> - property object representing a cell array of strings
% * <stringProperty_help.html |stringProperty|> -  property object representing a simple string
% * <unsignedIntegerProperty_help.html |unsignedIntegerProperty|> -  property object representing an unsigned integer in a specified interval
% * <vectorProperty_help.html |vectorProperty|> - property object representing a numeric vector
%
%% Visualization package (+visviews)
% * <axesPanel_help.html |axesPanel|> - base class for an axes with fixed margins
% * <blockBoxPlot_help.html |blockBoxPlot|> - displays a boxplot of blocked function values by window
% * <blockHistogramPlot_help.html |blockHistogramPlot|> - displays histogram of block function values
% * <blockImagePlot_help.html |blockImagePlot|> - displays element vs block values as an image
% * <blockScalpPlot_help.html |blockScalpPlot|> - displays scalp map of block values
% * <clickable_help.html |clickable|> - base class for mouse click linkage among view panels
% * <cursorExplorable_help.html |cursorExplorable|> - base class for objects used with cursor explorer
% * <cursorExplorer_help.html |cursorExplorer|> - class that adds and supervises an exploratory data cursor
% * <dualView_help.html |dualView|> - two level-viewer with upper panel summaries and lower panel details
% * <elementBoxPlot_help.html |elementBoxPlot|> - displays a boxplot of block function values by element
% * <horizontalPanel_help.html |horizontalPanel|> - grid of horizontally arranged resizable panels
% * <plotConfig_help.html |plotConfig|> - GUI for configuring list of plots
% * <plotObj_help.html |plotObj|> - holds definition and and settings for a plot
% * <resizable_help.html |resizable|> - interface to be implemented to give components fixed margins
% * <signalHistogramPlot_help.html |signalHistogramPlot|> - display stacked view of individual element or window signals
% * <signalShadowPlot_help.html |signalShadowPlot|> - display element or window signals using shadow outline
% * <signalStackedPlot_help.html |signalStackedPlot|> - display stacked view of individual element or window signals
% * <tabPanel_help.html |tabPanel|> - tabbed panel for holding multiple summary views
% * <verticalPanel_help.html |verticalPanel|> - grid of vertically arranged resizable panels
%
%% Source
% Kay A. Robbins
% Copyright 2011 The University of Texas at San Antonio
