function SpectrogramAnalysis(dig,fontsize)

%%
fig=findall(0,'Tag','DigitizerControl:SpectrogramAnalysis');
if ishandle(fig)
    delete(fig);
end

fig=SMASH.MUI.DialogPlot('FontSize',fontsize);
fig.Hidden=true;
fig.Name='Spectrogram';
set(fig.Figure,'Tag','DigitizerControl:SpectrogramAnalysis');

%%
set(fig.Axes,'FontSize',fontsize,'XGrid','on','YGrid','on',...
    'YDir','normal');
SpectrogramImage=image('Parent',fig.Axes','Visible','off',...
    'CDataMapping','scaled');
xlabel(fig.Axes,'Time (s)');
ylabel(fig.Axes,'Frequency (Hz)');

%%
Digitizer=addblock(fig,'popup','Current digitizer:',{''},20);
N=numel(dig);
label=cell(N,1);
for n=1:N
    label{n}=dig(n).Name;
end
set(Digitizer(2),'String',label);

%set(Digitizer(2),'Callback',@updateSpectrogram)

Channel=addblock(fig,'popup','Current channel',...
    {'CH1' 'CH2' 'CH3' 'CH4'},20);

TimeRange=addblock(fig,'edit','Time range:',20);
set(TimeRange(2),'String','-inf +inf','UserData',[-inf +inf],...
    'Callback',@checkRange);
    function checkRange(src,~)
        new=get(src,'String');
        new=sscanf(new,'%g',2);
        if isempty(new)
            new=get(src,'UserData');
        end
        set(src,'String',sprintf('%+g +%g',new),'UserData',new);
    end

Update=addblock(fig,'button','Update spectrogram');
set(Update,'Callback',@updateSpectrogram);
TempObject=SMASH.SignalAnalysis.STFT([],1:100);
    function updateSpectrogram(varargin)
        WorkingButton(Update);
        CU=onCleanup(@() WorkingButton(Update));                
        current=get(Digitizer(2),'Value');
        channel=get(Channel(2),'Value');
        if ~dig(current).Channel(channel).Display
            set(SpectrogramImage,'Visible','off');
            errordlg('This channel is not active','Inactive channel');
            return
        end
        data=grab(dig(current),channel);
        t=data.Grid;        
        s=data.Data(:,1);
        TempObject.Measurement=reset(TempObject.Measurement,t,s);
        TempObject.Measurement=crop(TempObject.Measurement,...
            get(TimeRange(2),'UserData'));
        TempObject=partition(TempObject,'blocks',1000);
        result=analyze(TempObject);        
        z=result.Data;
        z=10*log10(z/max(z(:)));
        set(SpectrogramImage,'XData',result.Grid1,'YData',result.Grid2,...
            'CData',z,'Visible','on');
        cb=SMASH.MUI.Colorbar(fig.Axes);
        ylabel(cb.Handle,'Relative power (dB)')
        set(fig.Axes,'CLim',[-60 0]);
        colormap(fig.Axes,'jet');        
        axis(fig.Axes,'tight');
        source=[Digitizer(2) Channel(2)];
        label=cell(2,1);
        for n=1:2
            temp=get(source(n),'String');
            temp=temp{get(source(n),'Value')};
            label{n}=temp;
        end
        label=sprintf('%s ',label{:});
        title(label);
    end

Done=addblock(fig,'button',{' Done '});
set(Done,'Callback',@done)
    function done(varargin)
        delete(fig.Figure);
    end

%%
updateSpectrogram();
movegui(fig.Figure,'center');
fig.Hidden=false;

set(fig.Figure,'HandleVisibility','callback');

end