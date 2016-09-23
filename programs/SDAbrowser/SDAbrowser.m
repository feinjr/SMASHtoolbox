% UNDER CONSTRUCTION
function varargout=SDAbrowser()

if isdeployed
    varargout{1}=0;
end

% create dialog
object=SMASH.MUI.Dialog();
object.Hidden=true;
object.Name='SDA browser';

Dir=addblock(object,'edit','Location:',40);
File=addblock(object,'edit','File:',40);
FileButton=addblock(object,'button',{' Select file ',' Load file '});

gap=addblock(object,'text',' ',40); % extra gap
delete(gap);

Record=addblock(object,'popup','Record:',{' '},40);
RecordButton=addblock(object,'button',{' View ' ' Extract '});

Type=addblock(object,'text','Type: ',40);

Description=addblock(object,'medit','Description',40,5);
Update=addblock(object,'button',' Save description');

Done=addblock(object,'button',' Done ');

box(object,[Dir File FileButton]);
box(object,[Record RecordButton Type Description Update]);

% assign callbacks


% display dialog
locate(object,'center');
object.Hidden=false;

end