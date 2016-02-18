![alt text](./misc/SMASH LOGO medium.png)
Welcome to the distribution site for the SMASH toolbox.  The repository you see above contains the current version, which is available for download or Git clone/pull.  Some frequently asked questions are answered below.

## What is SMASH?

SMASH stands for Sandia Matlab AnalysiS Hierarchy. It's a fancy way of saying "a collection of MATLAB code". The acronym and logo are inspired by dynamic compression research, where experiments involve literal smashing. The goals of the toolbox are: 
- To reduce development time in data analysis programs. 
- To standardize analysis techniques across dynamic compression and high-energy density researchers. 
- To promote and encourage collaborate analysis of complicated measurements. 
- To serve as a unified distribution method for new ideas and concepts. 
The toolbox contains a "+SMASH" directory where most of the functions and class definitions are located. MATLAB treats this directory as a package, where the contents are accessed with dot notation. The toolbox also contains standard (non-package) directories for programs, documentation and examples.

## Who can use SMASH?

SMASH is currently licensed for government-use only.  If you have access to this webpage, you must have been granted access through an existing license.  You can download SMASH onto any computer owned by the organization (national laboratory, university, etc.) that holds this license.  Copies of SMASH may be shared between users within an organization but should *not* be shared between organizations.  This site is the best way of accessing the SMASH toolbox---copies shared between users may be out of date.

## How do I get SMASH?

If you've reached this web site, you have two options.  The "Download ZIP" button copes a current snapshot of the toolbox to your machine.  This is initially the easiest way to get SMASH, but you must repeat the process and copy over older versions manually. 

Ideally, you should set up Git to pull down updates incrementally.

## How do I setup and use Git?

Git can be used at the command line or through a graphical client. For Mac and Windows users, I recommend the SourceTree graphical client. In either case, configure Git to see the SMASH repository at `git@github.com:SMASHtoolbox/SMASHtoolbox.git`.  See this [page](https://help.github.com/articles/generating-an-ssh-key/) for help with generating an SSH key to allow your machine to communicate with GitHub.

Once you've configured Git (or your Git client), clone the remote repository to your machine with the name SMASHtoolbox. When changes are made to the gitlab repository, you call pull the latest version directly from the remote repository to your machine. In SourceTree, this operation is literally a single button click. If you make changes to SMASH, they must be added and committed to your local repository and then pushed to gitlab. The gitlab repository will only accept revisions from approved developers. To learn more about Git, visit http://git-scm.com.

## What does SMASH require?

SMASH runs within MATLAB on Mac, Linux, and Windows machines.  Although some features may work in much older releases, users are encouraged to use MATLAB release 2013a or later.  SMASH is ~99% compatible with the new graphics system introduced in the release 2014b, and we are gradually migrating to release 2015a.

## How do I configure MATLAB to use SMASH?

Make sure your copy of SMASH is located in a safe place on your machine. Subdirectories of your user directory or a documents directory are fine; the default download directory is probably not a good location.  If you downloaded a ZIP file, the directory may be named "smash.git"; you should rename this to "SMASHtoolbox". 

Add the "SMASHtoolbox" directory to your MATLAB path. The "Set Path" button on the MATLAB tool strip can usually do this for you. Use the "Add folder" button in the "Set Path" dialog box, not the "Add with Subfolders" button. The toolbox  can also be manually added to the path using `addpath(location)`. I generally do this in a startup file located on the MATLAB path.

## Do I really need a MATLAB startup file

Startup files aren't strictly required, but they turn out to be incredibly useful. You should really use them to tailor MATLAB to your needs.  Here's a very basic startup file (which must be named "startup.m") that places the toolbox and its programs on the MATLAB path.

```matlab
function startup()

addpath('~/SMASHtoolbox/');
loadSMASH -program *;

end
```

## How do I use SMASH?

SMASH does lots of things, so this question has no simple answer. There are several ways to learn more.
- Online documentation is available in MATLAB by typing `doc SMASH`. Hyperlinks allow you to navigate down and up the package hierarchy. 
- Check out the "documentation" folder inside the toolbox for SAND reports on specific topics. 
- Some demonstrations are available in the "examples" folder. 
- Stop by one of the monthly meetings to talk to other users and developers.
- Contact the package developer(s) as necessary.

## What's inside SMASH?

SMASH composed of packages and programs.  Packages contain functions and classes for general use, while programs are self-contained collections of code.  To illustrate the difference, consider the Signal class in the SignalAnalysis package.
```matlab
object=SMASH.SignalAnalysis.Signal();
```
This command tells MATLAB to create a Signal object, which is based on a class in the SignalAnalysis package; package/sub-package names are separated by dots.  The Signal class proves general-purpose tools for all kinds of signal analysis.  There is another class in the same package called SignalGroup that provides a slightly different set of tools.  
```matlab
object=SMASH.SignalAnalysis.Signal();
```
All classes and functions in a package can be accessed in this fashion.

Programs are more specific collections of MATLAB code.  For example, the SIRHEN program was designed to analyze PDV data, making it poorly suited to general-purpose signal analysis.  SIRHEN sits inside the "programs" directly, which is not on the MATLAB path by default.  The utility "loadSMASH" manages this for you.
```matlab
loadSMASH -program SIRHEN % add SIRHEN to the path
SIRHEN % launch the program
```
Programs usually involve lots of functions, but only a few of them (usually one) are available to end user.  In this example, that function is defined in the file "SIRHEN.m".

