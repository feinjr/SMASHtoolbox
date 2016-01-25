% comment Edit comments
%
% This method edits the comments for a PDV timing analysis.  The command:
%    comment(object);
%  shows existing comments and allows changes to be made.
%
% See also PDVtiming
%

%
% created December 14, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function object=comment(object)

label=sprintf('Comments for ''%s''',object.Experiment);
default=strtrim(object.Comment);

dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='Comments';

h=addblock(dlg,'medit',label,40,10);
set(h(end),'String',default);

hButton=addblock(dlg,'button',{' OK ',' Cancel '});
set(hButton(1),'Callback',@OK);
    function OK(varargin)
        answer=probe(dlg);
        object.Comment=answer{1};
        delete(dlg.Handle);
    end
set(hButton(2),'Callback',@cancel)
    function cancel(varargin)
        delete(dlg.Handle);
    end

locate(dlg,'center');
dlg.Hidden=false;
dlg.Modal=true;

% answer=inputdlg(label,'Object comments:',[10 80],default);
% if isempty(answer)
%     return
% else
%     object.Comment=answer{1};
% end

end