# Welcome to the SMASH toolbox 

## What is SMASH?

SMASH stands for Sandia Matlab AnalysiS Hierarchy. It's a fancy way of saying "a collection of MATLAB code". The acronym and logo are inspired by dynamic compression research, where experiments involve literal smashing. The goals of the toolbox are: 
- To reduce development time in data analysis programs. 
- To standardize analysis techniques across dynamic compression and high-energy density researchers. 
- To promote and encourage collaborate analysis of complicated measurements. 
- To serve as a unified distribution method for new ideas and concepts. 
The toolbox contains a "+SMASH" directory where most of the functions and class definitions are located. MATLAB treats this directory as a package, where the contents are accessed with dot notation. The toolbox also contains standard (non-package) directories for programs, documentation and examples.

## Who can use SMASH

Licensed users...

## How do I get SMASH?

If you've reached this web site, you have two options.  The "Download ZIP" button copes a current snapshot of the toolbox to your machine.  This is initially the easiest way to get SMASH, but you must repeat the process and copy over older versions manually. 

Ideally, you should set up Git to pull down updates incrementally.

## How do I setup and use Git?

Git can be used at the command line or through a graphical client. For Mac and Windows users, I recommend the SourceTree graphical client. In either case, configure Git to see the SMASH repository at git@github.com:SMASHtoolbox/SMASHtoolbox.git.  See this [page](https://help.github.com/articles/generating-an-ssh-key/) for help with generating an SSH key to allow your machine to communicate with GitHub.

Once you've configured Git (or your Git client), clone the remote repository to your machine with the name SMASHtoolbox. When changes are made to the gitlab repository, you call pull the latest version directly from the remote repository to your machine. In SourceTree, this operation is literally a single button click. If you make changes to SMASH, they must be added and committed to your local repository and then pushed to gitlab. The gitlab repository will only accept revisions from approved developers. To learn more about Git, visit http://git-scm.com.

## How do I configure MATLAB to use SMASH?

Make sure your copy of SMASH is located in a safe place on your machine. Subdirectories of your user directory or a documents directory are fine; the default download directory is probably not a good location.  If you downloaded a ZIP file, the directory may be named "smash.git"; you should rename this to "SMASHtoolbox". 

Add the "SMASHtoolbox" directory to your MATLAB path. The "Set Path" button on the MATLAB tool strip can usually do this for you. Use the "Add folder" button in the "Set Path" dialog box, not the "Add with Subfolders" button. The toolbox  can also be manually added to the path using `addpath(location)`. I generally do this in a startup file "startup.m" located in a directory on the MATLAB path.

## Do I really need a MATLAB startup file

Startup files aren't strictly required, but they turn out to be incredibly useful. You should really use them to tailor MATLAB to your needs.  Here's a very basic startup file that places the toolbox and its programs on the MATLAB path.

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