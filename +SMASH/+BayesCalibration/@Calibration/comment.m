% comment Edit comments associated with an object
%
% This method edits the "Comemnts" property of an object.  When invoked:
%    >> object=comment(object);
% a graphical window shows the existing description and allow changes to be
% made.
%
% See also DataClass
%

%
% created November 14, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=comment(object)

label=sprintf('Comments for Calibration object');
default={strtrim(object.Comments)};
answer=inputdlg(label,'Object comments:',[10 80],default);
if isempty(answer)
    return
else
    object.Comments=answer{1};
end

end