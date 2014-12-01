%% Dialog example B : non-modal dialog box with a large font
object=SMASH.MUI.Dialog('FontUnits','points','FontSize',20);
object.Name='Example B';
object.Hidden=true;

set(object.Handle,'CloseRequestFcn','return'); % disable standard closing calls
set(object.Handle,'HandleVisibility','callback'); % discourage direct user access

addblock(object,'listbox','Items:',{'Item A','Item B','Item C'})
h=addblock(object,'button',{' OK ',' Apply ',' Cancel '});

set(h(1),'Callback','obj=get(gcbf,''UserData'');state=obj.probe,fprintf(''Do something\n'');delete(gcbf)');
set(h(2),'Callback','obj=get(gcbf,''UserData'');state=obj.probe,fprintf(''Do something\n'');');
set(h(3),'Callback','delete(gcbf);');

locate(object,'northeast');
object.Hidden=false;