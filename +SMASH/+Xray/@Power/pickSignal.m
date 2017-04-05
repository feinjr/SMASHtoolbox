function object=pickSignal(object)

SignalIndex = object.Settings.SignalIndex;
temp = SignalIndex;

%Generate the figure object
fig = SMASH.MUI.Figure; fig.Hidden = true;
fig.Name = 'pickTimes GUI';
set(fig.Handle,'Tag','pickTimesGUI');
set(fig.Handle,'Units','normalized');
set(fig.Handle,'Position',[0.05 0.05 .75 .8]);
%set(fig.Handle,'Toolbar','figure');
ax1=axes('Parent',fig.Handle,'Units','normalized','OuterPosition',[0.1 0.1 0.8 0.8]);
ylabel('Signal');
xlabel('Time')

% create Times menu
hm=uimenu(fig.Handle,'Label','Signal');
uimenu(hm,'Label','Save Signal','Callback',@SaveCallback);

Nsig = size(object.RawSignal.Data,2);
hl = zeros(Nsig,1);
cmap = colormap(lines);
for i = 1:Nsig
    hl(i) = line(object.RawSignal.Grid,object.RawSignal.Data(:,i),'Color',cmap(i,:));
    set(hl(i),'ButtonDownFcn',@SelectCallback)
end

fig.Hidden = false;

waitfor(fig.Handle)

object.Settings.SignalIndex = SignalIndex
%object = configure(object,'FitSignal',SignalIndex);
%% Callbacks
function SelectCallback(src,evnt)
    sel_typ = get(gcbf,'SelectionType');
    switch sel_typ 
      case 'normal'
         set(src,'Selected','on','LineWidth',2)    
         temp = find(hl == src);
         nottemp = find(hl~=src);
         for j = 1:numel(nottemp)
            set(hl(nottemp(j)),'Selected','off','LineWidth',0.5)     
         end
      case 'extend'
         set(src,'Selected','off','LineWidth',0.5)
         temp = SignalIndex;
      case 'alt'
         set(src,'Selected','off','LineWidth',0.5)
         temp = SignalIndex;
    end
end


function SaveCallback(src,evnt)
    SignalIndex = temp;
    object.Settings.FitSignal = SignalIndex
    close(fig.Handle)
end

end
