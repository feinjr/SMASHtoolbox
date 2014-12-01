% COMMENT Edit comments associated with an object
%
% This method edits the "Comments" property of an object.  When invoked:
%    >> object=comment(object);
% a graphical window is created to show existing comments and allow changes
% to be made.
%
% See also DataClass
%

%
% created November 14, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=comment(object)

label=sprintf('Comment for ''%s''',object.Name);
default={strtrim(object.Comments)};
answer=inputdlg(label,'Image comment',[10 80],default);
if isempty(answer)
    return
else
    object.Comments=answer{1};
end

end