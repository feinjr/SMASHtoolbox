function DialogTrigger(~,~,object)

dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name=sprintf('%s triggering',object.Experiment);

h=addblock(dlg,'table',...
    {'DIG' 'Trigger'},...
    [5 10],10);
set(h(1),'TooltipString','Digitizer number');
set(h(2),'TooltipString','Trigger time');



dlg.Hidden=false;

end