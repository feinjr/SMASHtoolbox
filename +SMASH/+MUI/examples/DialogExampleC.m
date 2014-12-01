% exampleC : dialog box created inside a function
% initial rendering is slow because the dialog isn't hidden
function value=DialogExampleC()

% create the dialog
object=SMASH.MUI.Dialog();
object.Name='Example C';
label={'Input file name',' select '};
h=addblock(object,'edit_button',label,40);
FileBox=h(2);
set(h(3),'Callback',@ChooseFile);
    function ChooseFile(varargin)
        current=get(FileBox,'String');
        [pathname,~]=fileparts(current);
        [filename,pathname]=uigetfile('*.*','Choose input file',pathname);
        if isnumeric(filename)
            return
        end
        set(FileBox,'String',fullfile(pathname,filename));
        
    end

label={'Input parameter: ','fixed'};
h=addblock(object,'edit_check',label);
ParameterBox=h(2);
set(ParameterBox,'String',1);
set(h(3),'Callback',@FixParameter);
    function FixParameter(src,varargin)
        if get(src,'Value') % check is on
            set(ParameterBox,'Enable','off');
        else % check is off
            set(ParameterBox,'Enable','on');
        end        
    end

h=addblock(object,'button',' OK ');
set(h,'Callback',@OKcallback);
    function OKcallback(varargin)
        obj=get(gcbf,'UserData');
        obj.Modal=false;
    end

locate(object,'center');

% make the dialog modal and wait until things change
object.Modal=true;
waitfor(object.Handle,'WindowStyle'); % wait until modal operations end
if ~isvalid(object) % dialog was closed
    value=[];
    return
end
value=probe(object);
delete(object);

end