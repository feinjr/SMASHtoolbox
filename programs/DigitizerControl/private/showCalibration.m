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
        %
        data=get(General(end),'Data');        
        data{1,2}=dig(k).Calibration.Tshift.Regular;
        data{1,3}=dig(k).Calibration.Date.Regular;
        data{2,2}=dig(k).Calibration.Tshift.TimeScale;
        data{2,3}=dig(k).Calibration.Date.TimeScale;
        set(General(end),'Data',data);
        % 
        data=get(Channel(end),'Data');
        data{1,2}=checkPass(dig(k).Calibration.Status.Channel1Vertical);
        data{1,3}=checkPass(dig(k).Calibration.Status.Channel1Trigger);
        data{2,2}=checkPass(dig(k).Calibration.Status.Channel2Vertical);
        data{2,3}=checkPass(dig(k).Calibration.Status.Channel2Trigger);
        data{3,2}=checkPass(dig(k).Calibration.Status.Channel3Vertical);
        data{3,3}=checkPass(dig(k).Calibration.Status.Channel3Trigger);
        data{4,2}=checkPass(dig(k).Calibration.Status.Channel4Vertical);
        data{4,3}=checkPass(dig(k).Calibration.Status.Channel4Trigger);
        data{5,3}=checkPass(dig(k).Calibration.Status.AuxTrigger);
        set(Channel(end),'Data',data);
    end

General=addblock(box,'table',{'' 'T change (C)' 'Date'},[10 5 20],2);
data=get(General(end),'Data');
data{1,1}='Regular';
data{2,1}='Time scale';
set(General(end),'Data',data,'ColumnEditable',false);

Channel=addblock(box,'table',{'Input' 'Vertical' 'Trigger'},10,5);
data=get(Channel(end),'Data');
for n=1:5
    if n <=4
        data{n,1}=sprintf('Channel %d',n);
    else
        data{n,1}='Aux';
    end
end
set(Channel(end),'Data',data,'ColumnEditable',false);

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

function result=checkPass(value)

switch value
    case 1
        result='Passed';
    case 0
        result='Failed';
    otherwise
        result='';
end

end