% This function displays version information for the SMASH package.
% Information can be displayed in the command window:
%    >> SMASH.info
% or returned in a structure.
%    >> a=SMASH.info;
%
% See also SMASH
%

% 
% created May 15, 2014 by Daniel Dolan (Sandia National Laboratories)
% revised November 17, 2014 by Daniel Dolan
%     -cleaned up interface to *.git subfolder
function varargout=SMASHinfo(varargin)

% current version number (set by developer)
data.VersionNumber='1.0 alpha';

% latest revision date
location=mfilename('fullpath');
[location,~]=fileparts(location);
target=fullfile(location,'*.git');
target=dir(target);
if numel(target)==1
    data.Committed=target.date;
else
    data.Committed='unknown';
end

% handle output
if nargout==0
    fprintf('\n');
    fprintf('SMASH package information:\n');
    format='%10s : %s\n';
    fprintf(format,'version',data.VersionNumber);
    fprintf(format,'committed',data.Committed);
    fprintf('\n')
else
    varargout{1}=data;
end

end