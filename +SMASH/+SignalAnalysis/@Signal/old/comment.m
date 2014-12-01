% COMMENT Manage comments in a Image object
%
% Usage:
%   >> object=comment(object); % displays comments in an edit window
%
% See also IMAGE

% created November 9, 2012 by Daniel Dolan (Sandia National Laboratories)
% revised November 15, 2012 by Daniel Dolan
%   -removed extraneous white space from comments
% modified by October 17, 2013 by Tommy Ao (Sandia National Laboratories)
%
function object=comment(object)

label=sprintf('Comment for ''%s''',object.Title);
default={strtrim(object.Comment)};
answer=inputdlg(label,'Image comment',[10 80],default);
if isempty(answer)
    return
else
    object.Comment=answer{1};
end

end