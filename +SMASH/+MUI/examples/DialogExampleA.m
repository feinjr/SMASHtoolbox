%% Dialog example A : modal dialog
object=SMASH.MUI.Dialog;
object.Name='Example A';
object.Hidden=true; % temporarily hide dialog for speed

h=addblock(object,'edit','Input something:'); % edit block
set(h(2),'String','abc'); % place a default value in the edit box
h=addblock(object,'edit','Input something else:',20); % another edit block
set(h(2),'String','123'); % place a default value in the edit box
addblock(object,'check','Binary choice'); % check box block
choices={'Choice A','Choice B','Choice C'};
addblock(object,'popup','Make a choice:',choices); % popup menu block

h=addblock(object,'button',' OK '); % button block
callback='obj=get(gcbf,''UserData'');value=probe(obj);delete(obj);'; % root workspace
set(h,'Callback',callback); % button probes dialog state and closes it

object.Hidden=false; % reveal finished dialog
%object.Modal=true;