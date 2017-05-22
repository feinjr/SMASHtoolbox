function FFTanalysis(dig,fontsize)

%%
fig=findall(0,'Tag','DigitizerControl:FFTanalysis');
if ishandle(fig)
    delete(fig);
end

fig=SMASH.MUI.DialogPlot('FontSize',fontsize);
fig.Hidden=true;
fig.Name='Frequency spectra';
set(fig.Figure,'Tag','DigitizerControl:FFTanalysis');

%%
set(fig.Axes,'FontSize',fontsize,'Color','k',...
    'GridColor','w','XGrid','on','YGrid','on');
color={'y' 'g' 'b' 'r'};
Nchannel=4;
for k=1:Nchannel
    ChannelLine(k)=line('Parent',fig.Axes,'Visible','off'); %#ok<AGROW>
    if k==1        
        ChannelLine=repmat(ChannelLine,4,1);           
    end
    set(ChannelLine(k),...
        'Color',color{k},'Tag',sprintf('Channel%d',k));
end
xlabel(fig.Axes,'Frequency (Hz)');
ylabel(fig.Axes,'Relative power (dB)');

%%
Digitizer=addblock(fig,'popup_button',{'Current digitizer:' ' Update '},...
    {''},20);
N=numel(dig);
label=cell(N,1);
for n=1:N
    label{n}=dig(n).Name;
end
set(Digitizer(2),'String',label);
set(Digitizer(2:3),'Callback',@updateSpectra)
TempObject=SMASH.SignalAnalysis.Signal([],1);
    function updateSpectra(varargin)
        OriginalColor=get(Digitizer(3),'BackgroundColor');
        set(Digitizer(3),'BackgroundColor','m');
        drawnow();
        current=get(Digitizer(2),'Value');
        data=grab(dig(current));
        summary=cell(4,3);
        index=0;
        label={};
        for kk=1:4
            if ~(dig(current).Channel(kk).Display)
                set(ChannelLine(kk),'Visible','off','XData',[],'YData',[]);                
            else
                index=index+1;
                TempObject=reset(TempObject,data.Grid,data.Data(:,index));
                TempObject=regrid(TempObject);
                [f,P]=fft(TempObject,'RemoveDC',true);
                P=10*log10(P/max(P));
                set(ChannelLine(kk),'XData',f,'YData',P,'Visible','on');
                if get(Enable,'value')                    
                    temp=summarize(TempObject,'sinusoid');
                    summary{index,1}=sprintf('%d',kk);
                    summary{index,2}=SMASH.General.enprint(temp.Sinusoid.Frequency,3);
                    summary{index,3}=sprintf('%#.3g',temp.Sinusoid.Fraction*100);
                end                                                
            end            
        end
        axis(fig.Axes,'auto');
        set(Table(end),'Data',summary);
        set(Digitizer(3),'BackgroundColor',OriginalColor);
    end

Enable=addblock(fig,'checkbox','Summarize');
set(Enable,'Callback',@enableSummary)
    function enableSummary(varargin)
        if get(Enable,'Value')
            set(Table,'Visible','on');
            updateSpectra();
        else
            set(Table,'Visible','off');
        end
    end
Table=addblock(fig,'table', {'Ch' 'Freq. (Hz)' 'Noise (%)'},...
    5,4);
enableSummary();

Done=addblock(fig,'button',{' Done '});
set(Done,'Callback',@done)
    function done(varargin)
        delete(fig.Figure);
    end

%%
updateSpectra();
movegui(fig.Figure,'center');
fig.Hidden=false;

set(fig.Figure,'HandleVisibility','callback');

end