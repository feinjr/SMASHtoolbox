function destroy(object,~)

if isa(object,'handle') && ishandle(object.Handle) % delete dialog when object is deleted
    delete(object.Handle);
    fig=findall(0,'Type','figure');
    for k=1:numel(fig)
        h=getappdata(fig(k),'SourceFigure');
        if isempty(h) || (h~=object.Handle)
            continue
        end
        delete(fig(k));
    end
elseif ishandle(object) % delete object when dialog is closed/deleted
    target=get(object,'UserData');
    delete(target)
end

end