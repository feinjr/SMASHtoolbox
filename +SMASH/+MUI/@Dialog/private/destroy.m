function destroy(object,~)

if isa(object,'handle') && ishandle(object.Handle) % delete dialog when object is deleted
    delete(object.Handle);
elseif ishandle(object) % delete object when dialog is closed/deleted
    target=get(object,'UserData');
    delete(target)
end

end