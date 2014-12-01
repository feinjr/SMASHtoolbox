% STORE Store object for later use
%
% This method stores Signal objects in an archive (*.sda file), which can
% be reloaded into MATLAB at a later time.  The calling syntax is:
%    >> store(object,filename,label,[description],[deflate]);
% If the specified file does not already exist, it is created.  Stored
% objects are appended to existing archives unless the requested label is
% already present; if this is the case, an error is thrown.
%
% A conceptual work cycle is shown below.
%    >> store(object,'results.sda','record A');
%    >> clear all
%    >> object=Signal('restore','results.sda','record A');
%
% See also Signal, export
%

%
% created October 5, 2013 by Daniel Dolan (Sandia National Laboratories) 
%
function store(object,filename,label,description,deflate)

% handle input
assert(nargin>=3,'ERROR: file name and archive label are required')

if (nargin<4) || isempty(description)
    description='';
end

if (nargin<5) || isempty(deflate)
    deflate=1;
end

% create temporary structure of object properties
field=properties(object);
temp=struct();
for n=1:numel(field)
    temp.(field{n})=object.(field{n});
end

archive=SMASH.FileAccess.SDAfile(filename);
insert(archive,label,temp,description,deflate);
h5writeatt(filename,['/' label],'Class',class(object));
h5writeatt(filename,['/' label],'RecordType','object');

end