function makeGUI()

fig=SMASH.MUI.DialogPlot();
fig.Name='Digitizer control';

xlabel(fig.Axes,'Time (s)');
ylabel(fig.Axes,'Signal (V)');

h=findobj(gcf,'Type','uitoggletool','Tag','standard');
set(h,'Enable','off');

hm=uimenu(fig.Figure,'Label','Program');
uimenu(hm,'Label','Configure digitizer(s)');
uimenu(hm,'Label','Save configuration');
uimenu(hm,'Label','Load configuration');
uimenu(hm,'Label','Pull calibrations','Separator','on');
uimenu(hm,'Label','Push calibrations');
uimenu(hm,'Label','Exit','Separator','on');

hm=uimenu(fig.Figure,'Label','Analysis');
uimenu(hm,'Label','Frequency spectrum');
uimenu(hm,'Label','Time-frequency spectrogram');

digitizer=addblock(fig,'popup_button',{'Digitizer:' ' Select '},...
    {'Digitizer 1' 'Digitizer 2' 'Digitizer 3' 'Digitizer 4'},20);

%addblock(fig,'popup','Digitizer:',...
%    {'Digitizer 1' 'Digitizer 2' 'Digitizer 3' 'Digitizer 4'},20);

acquire=addblock(fig,'table',{'Setting' 'Value'},10,8);
addblock(fig,'button','Appy to all');


channel=addblock(fig,'table',{'Ch' 'Scale' 'Offset' 'On'},[3 10 10 3],4);

addblock(fig,'button',{' Arm ' ' Stop '});

movegui(fig.Figure,'center');

end