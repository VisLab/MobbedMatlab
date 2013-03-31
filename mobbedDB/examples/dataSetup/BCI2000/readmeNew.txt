These are scripts to convert the 109 subject BCI-2000 data (.edf) to 
EEGLAB data format (.set). Details about the collection and how to
downlowd it are available in the articles acknowledged below.

The scripts are:
    edf2setBCI2000.m    converts a full directory tree of .edf data to .set
    set2matBCI2000.m    converts a full directory tree of .set data to .edf

The scripts rely on conversion routines from EEGLAB. EEGLAB and its
subdirectories must be in the path.

Input data:
The input assumes that data is in a directory BCI2000 with the files 
for subject 1 in subdirectory S001 and the files for
subject 109 in the subdirectory S109. Each subject has 14 runs. The
files for the first run of subject 1 are S001R01.edf and S001R01.edf.event,
respectively.

Output data:
The output appears in a "root" directory organized into subfolders by
subject. This root directory should exist before calling edf2setBCI2000.

Event names:
Original datasets have only three event labels: T0, T1, and T2 and use
the filenames to interpret the event labels in terms of tasks as 
summarized by the following table:

Task	Files           Motion type         Original event label
                                      T0              T1          T2
---------------------------------------------------------------------------
BASE1	R01             None        Eyes open		
BASE2	R02             None        Eyes closed		
TASK1	R03, R07, R11	Real        Rest            Left fist	Right fist
TASK2	R04, R08, R12	Imagined	Rest            Left fist	Right fist
TASK3	R05, R09, R13	Real        Rest            Both fists	Both feet
TASK4	R06, R10, R14	Imagined	Rest            Both fists	Both feet

To convert the event labels to represent unique actions, we prepend the
task name to the original event label in the conversion.


Example:
The S001R03.edf and S001R04.edf file names designate TASK 1 and TASK 2
from subject 1 (S001). Both files contain the same event labels, T0, T1, and T2.
However, T1 in file S001R03 corresponds to real opening and closing of 
the left fist, while T1 in file S001R04 corresponds to imagined opening
and closing of the left fist. After running the conversion program 
(edf2setBCI2000.m),  T1 in S001R03 is renamed as TASK1T1, while T1 in
S001R04 is renamed as TASK2T1.




------------------------------------------------------------------------------
Acknowledgments:
This data collection is described in the following study:
     Schalk, G., McFarland, D.J., Hinterberger, T., Birbaumer, N., Wolpaw, J.R. 
     BCI2000: A General-Purpose Brain-Computer Interface  (BCI) System.
     IEEE Transactions on Biomedical Engineering 51(6):1034-1043, 2004. 

Also see the BCI2000 website: www.bci2000.org.
    
The data collection is hosted on Physionet:
    Goldberger AL, Amaral LAN, Glass L, Hausdorff JM, Ivanov PCh, 
    Mark RG, Mietus JE, Moody GB, Peng C-K, Stanley HE. 
    PhysioBank, PhysioToolkit, and PhysioNet: Components of a New 
    Research Resource for Complex Physiologic Signals. 
    Circulation 101(23):e215-e220,  2000 (June 13). 
    [Circulation Electronic Pages; 
    http://circ.ahajournals.org/cgi/content/full/101/23/e215] 