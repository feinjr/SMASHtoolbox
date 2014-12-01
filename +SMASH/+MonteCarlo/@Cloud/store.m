% store Store Cloud in an archive file
%
% This function store data clouds in an archive file for later use.  The
% extension for these files is *.cld, and other extensions will be
% overridden to enforce consistency.
%    >> store(object,filename);
%
% See also Cloud
%

%
% created July 21, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function store(object,filename)

% handle input
if (nargin<2) || isempty(filename)
    error('ERROR: no file specified');
end

% force *.cld extension (cloud)
[pathname,filename,ext]=fileparts(filename);
if ~strcmpi(ext,'.cld')
    fprintf('Changing extension to .cld (data cloud)\n');
    ext='.cld';
end
filename=fullfile(pathname,[filename ext]);

% store object proprties as structure fields
s=warning('query','MATLAB:structOnObject');
warning('off',s.identifier);
data=struct(object); %#ok<NASGU>
warning(s.state,s.identifier);
save(filename,'data','-v7.3');

end