README FILE
-----------------------------------------------------------
Mobbed 1.0a Beta
by Kay Robbins/Jeremy Cockfield/Arif Hossain 
-----------------------------------------------------------
Contents:
I.   WHAT IS MOBBED 
II.  SYSTEM REQUIREMENTS
III. GETTING STARTED 
IV.  TECHNICAL SUPPORT
V.   ADDITIONAL INFORMATION
 
I. WHAT IS MOBBED 
 
Mobbed is a lightweight, easy-to-use, extensible toolkit that allows users to incorporate
a computational database into their normal MATLAB workflow. Although capable of storing
quite general types of annotated data, Mobbed is particularly well-suited to multichannel
time series such as EEG that have event streams overlaid with sensor data. 

II. SYSTEM REQUIREMENTS 

1) Operating System
* Windows 7 
* Ubuntu

2) Matlab 
* 2012a

3) Postgresql
* 9.2

III. GETTING STARTED

Open up MATLAB. Add the Mobbed directory and its subdirectories to the workspace. 

1) Creating a database:
* execute setup.m to add the .jar files to the path that have been distrubuted with Mobbed. 
* call the createdb method in the Mobbed.m class using the appropriate database credentials. 

2) Deleting a database: 
* execute setup.m to add the .jar files to the path that have been distrubuted with Mobbed. 
* call the deletedb method in the Mobbed.m class using the appropriate database credentials. 

Examples of how to use Mobbed are in the examples directory. These examples can be found
in the papers such as the user manual with detailed explainations of what they do. Please
download the sample data, MobbedTestData.zip and include in the workspace prior to running
these because some of the examples are dependent on this data. Users are highly encouraged
to read ALL documentation to gain an understanding of how Mobbed works and how to extend 
its functionality. 

IV. TECHNICAL SUPPORT

If you need technical assistance, you may contact us on our website, 
http://visual.cs.utsa.edu/contact-info. Please provide a name, email address, subject, 
and message. 

V. ADDITIONAL INFORMATION

For additional information please see:

CS-TR-2013-005, http://venom.cs.utsa.edu/dmz/techrep/2013/CS-TR-2013-005.pdf,
by Jeremy Cockfield, Kyung Min Su and Kay Robbins, Department of Computer Science, 
University of Texas at San Antonio, Apr. 2013

CS-TR-2013-006, http://venom.cs.utsa.edu/dmz/techrep/2013/CS-TR-2013-006.pdf,
by Jeremy Cockfield, Kyung Min Su and Kay Robbins, Department of Computer Science,
University of Texas at San Antonio, Apr. 2013

