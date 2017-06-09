function showCalibration(dig,fontsize)

%%
box=SMASH.MUI.Dialog('FontSize',fontsize);
box.Name='Digitizer calibration';
box.Hidden=true;

%%
N=numel(dig);
choice=cell(N,1);
for n=1:N
    choice{n}=dig(n).Name;
end
Digitizer=addblock(box,'popup_button',{'Digitizer' ' Refresh '},choice,20);
set(Digitizer([1 end]),'Callback',@refresh);
    function refresh(varargin)
        k=get(Digitizer(2),'Value');        
        data=dig(k).Calibration;
        set(Report(end),'Data',data);
    end

Report=addblock(box,'table',{''},40,10);
set(Report(end),'ColumnEditable',false,'BackgroundColor',ones(2,3));
refresh();


Done=addblock(box,'button',{' Done '});
set(Done,'Callback',@done)
    function done(varargin)
        delete(box);
    end

%%

refresh()
movegui(box.Handle,'center');
box.Hidden=false;
box.Modal=true;

end