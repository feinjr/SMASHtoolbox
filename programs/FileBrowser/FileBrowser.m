% FileBrowser Interactive file browser
function varargout=FileBrowser(varargin)

% create dialog if it doesn't already exist
h=findobj(0,'Type','figure','Tag','SMASH:FileBrowser');
if ishandle(h)
    figure(h);
    fig=getappdata(h,'DialogObject');
else
    fig=createDialog;
end

% manage output
if nargout>0
    varargout{1}=fig;
end



end