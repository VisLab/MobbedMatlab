%% EEGVIS: Getting Started
%
%% Acknowledgements
% The EEGVIS toolkit is being developed as part of the Army Research Laboratories
% CAN-CTA Neuroergonomics Project. Also acknowledged are SCCN and
% the <http://sccn.ucsd.edu/eeglab EEGLAB> team at University of 
% California at San Diego.
%
%% Overview
% EEGVIS provides a visualization tools and a development infrastructure
% for quickly viewing data such as continuously recorded EEG, which
% can be large and exhibit widely varying scales. A typical EEG apparatus 
% might record 128 channels at 512 Hz resulting in about 4 million data 
% points per minute. While normal EEG signals tend to vary on a scale of 
% approximately 100 microvolts, a loose connector can result in voltages in the 
% tens of thousands of microvolts. 
%
% EEGVIS uses a flexible drill-down strategy to summarize the data and to 
% all users to examine more closely areas of
% interest. The following screenshot illustrates the viewer for an EEG 
% data set with 32 channels and over 30K frames or time samples. 
% The top portion contains multiple summary views organized by tabs. 
% Each of the top tab panels shows a summary (kurtosis and standard 
% deviation, respectively) computed on windows of 1000 frames giving 
% 31 windows of blocks. The kurtosis (K) tab (visible) shows three 
% summary views: the distribution of kurtosis for each frame 
% (left boxplot), the distribution of the kurtosis by frame and channel 
% (middle image), and the distribution of kurtosis by channel (right boxplot). 
% When the user clicks on one of these summary views, the detail panels 
% display the clicked region.
%
% The bottom portion contains various detail panels, which display 
% relatively small portions of the data. A user selects detail views 
% by clicking a summary view. The user can configure the arrangement 
% of viewing panels and how summary and detail panels link. The viewer
% also supports cursor exploration as shown in the middle top panel of
% the screenshot below.
% 
% *Screenshot of the main viewer for an EEG data set with 32 channels.*
% (from the EEGLAB distribution).
% 
% <html>
% <img src = "eegvis.png" alt = "Screenshot of eegvis for EEG
% dataset"/>
% </html>
%
%% Installation
%
% The EEGVIS viewer (|eegvis|) can be used as a function called from
% a MATLAB script, as part of <http://sccn.ucsd.edu/eeglab EEGLAB>, or
% as a standalone program, completely independently of MATLAB. 
%
% *To use as a function in MATLAB:*
% 
% * Download the distribution and unzip to a convenient directory.
% * Add the |eegvis| directory and all of its subdirectories to the MATLAB
% path. (You can set the path through the MATLAB File menu.)
%
% *To use as an EEGLAB plugin:*
%
% * Download the distribution and unzip into the EEGLAB |plugins| directory.
% Note: the |eegvis| directory should be directly beneath the EEGLAB
% |plugins| directory.
% * Start EEGLAB. This will cause EEGLAB to add the necessary directories
% to the MATLAB path.
%
% *To use as a standalone program:*
%
% * Download the standalone version and unzip.
% * Create a shortcut to the program on your desktop.
%
%% Running the EEGVIS viewer as a function in MATLAB.
% The following example shows how to display an EEGVIS figure window for a
% a 3D array of data from within MATLAB. Type the following in the
% MATLAB command window:

   data = random('exp', 2, [32, 1000, 20]);
   hfig = eegvis(data);

%% Using the cursor explorer with the EEGVIS viewer
% To enable the cursor explorer for |eegvis|, press the following
% button on the |eegvis| toolbar:
%
% <html>
% <img src = "cursorExploreIcon.png" alt = "Cursor explorer icon"/>
% </html>
% 
% In cursor exploration mode, you can move the cursor over an |eegvis|
% figure window and continuously read out the values represented in the
% visualization panel. Cursor exploration mode disables pan, zoom and
% the MATLAB data cursor.
%
%% The standalone EEGVIS browser
% The |eegbrowse| function provides a standalone method of quickly browsing 
% EEG data sets as shown in the following screenshot. This function relies
% EEGLAB libraries for input. *Add |EEGLAB| and its subdirectories to the
% MATLAB path prior to running this function.*
%
% After moving to a directory containing |.set| files, click on a file 
% name to choose a file. The actions |eegbrowse| takes depend on the state 
% of the check boxes at the bottom of the screen. If you check  
% |Load workspace|, |eegbrowse| loads the selected file into the 
% MATLAB workspace as an EEGLAB EEG structure. If you check 
% |Preview|, |eegBrowse| displays an |eegvis| figure window 
% with the data. If you check |New figure|, |eegbrowse| 
% displays each preview in a new |eegvis| figure. 
% 
% Currently |eegbrowse| only works for EEGLAB |.set| files, but support 
% for additional formats should be available soon. 
%
% *Screenshot of the eegBrowse previewer*
% 
% <html>
% <img src = "eegbrowse.png" alt = "Screenshot of eegbrowse"/>
% </html>
%
%
%% Running the EEGVIS browser (|eegbrowse|) 
% To run standalone EEG browser type the following command: 

     eegbrowse();

%% Running eegbrowse and eegvis functions from the EEGLAB menus
%
% The |eegbrowse| function integrates into the
% EEGLAB framework under the File menu as illustrated below. You can 
% bring up |eegbrowse| to quickly look at your files before deciding
% what to load into EEGLAB. The |eegvis| function integrates under
% the Plot menu to display the current dataset.
%
% *Screenshot of the eegBrowse access through EEGLAB*
%
% <html>
% <img src = "eeglab.png" alt = "Screenshot of eegBrowse in EEGLAB"/> 
% </html>
%
% *Note:* Prior to EEGLAB version 11, the preview appears grayed out
% on the File menu until at least one dataset has been loaded. 
%
%% See also
% <eegvis_help.html |eegvis|> and <dualView_help.html |visviews.dualView|>