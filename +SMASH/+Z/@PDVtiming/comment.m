% comment Edit comments
%
% This method edits the comments for a PDV timing analysis.  The command:
%    comment(object);
%  shows existing comments and allows changes to be made.
%
% See also PDVtiming
%

%
% created December 14, 20135by Daniel Dolan (Sandia National Laboratories)
%
function object=comment(object)

label=sprintf('Comments for ''%s''',object.Experiment);
default={strtrim(object.Comment)};
answer=inputdlg(label,'Object comments:',[10 80],default);
if isempty(answer)
    return
else
    object.Comment=answer{1};
end

end