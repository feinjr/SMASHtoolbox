function runParanoid(master,dig,fontsize)

%%
box=SMASH.MUI.Dialog('FontSize',fontsize);
box.Hidden=true;
box.Name='Arm?';

addblock(box,'text','Arming clears unsaved data');
addblock(box,'text','Do you want to proceed?');
button=addblock(box,'button',{' Yes ' ' No '});
set(button,'Callback',@proceedButton);
    function proceedButton(src,~)
        name=strtrim(get(src,'String'));
        if strcmpi(name,'yes')
            proceed=true;
        end
        delete(box.Handle);
    end
proceed=false;

locate(box,'center');
box.Hidden=false;
box.Modal=true;
waitfor(box.Handle);
if ~proceed
    return
end

%%
default='C:\Users\Public\Documents\Infiniium';
command=sprintf('DISK:CDIRECTORY "%s"',default);
for k=1:numel(dig)
    fwrite(dig(k).VISA,command);
end

%%
ChannelLine=findobj(master.Axes,'Type','line');
set(ChannelLine,'Visible','off');
clearDisplay(dig);
lock(dig);

%%
set(master.Figure,'Visible','off');

box=SMASH.MUI.Dialog('FontSize',fontsize);
box.Hidden=true;
box.Name='Shot mode';

status=addblock(box,'text','FULLY ARMED',20);
set(status,'BackgroundColor','g','FontWeight','bold');

period=getappdata(master.Figure,'QueryInterval');
interval=addblock(box,'button',' Check status ');
set(interval(1),'Callback',@testNow)
    function testNow(varargin)
        WorkingButton(interval(1));
        C=onCleanup(@() WorkingButton(interval(1)));
        N=numel(dig);
        armed=false(N,1);
        testMessage={};
        for n=1:N
            delay=SMASH.System.ping(dig(n).System.Address);
            if isnan(delay)
                testMessage{end+1}=sprintf(...
                    '%s is not responding',dig(n).Name); %#ok<AGROW>
                continue
            end
            if strcmpi(dig(n).RunState,'single')
                armed(n)=true;                          
            end
        end
        Narmed=sum(armed);
        if Narmed == N
            % keep going
        elseif Narmed == 0
            set(status,'String','Disarmed','BackgroundColor','r');
            set(button,'String','Close','BackgroundColor',OriginalColor',...
                'Callback',@done);
            SystemArmed=false;
            command=sprintf(...
                'DISK:SAVE:WAVEFORM ALL, "AUTOSAVE.h5" ,H5INT, ON');
            for m=1:numel(dig)
                fwrite(dig(m).VISA,command);
            end
            set(autosave(1),'String','Data automatically saved to:');
            set(autosave(2),'String',...
                fullfile(sprintf('\t%s',default),'AUTOSAVE.h5'));
        else           
            index=find(~armed);
            for n=1:numel(index)
                testMessage{end+1}=sprintf('%s disarmed',...
                    dig(index(n)).Name); %#ok<AGROW>
            end
            set(status,'String','Partially armed','BackgroundColor','y');
        end
        set(problem(end),'Data',testMessage(:));
        TimerValue=0;
        drawTimer(TimerValue);
    end

problem=addblock(box,'table',{'Warnings:'},30,5);
set(problem(end),'ColumnEditable',false,'Data',{});

button=addblock(box,'button',' STOP ');
OriginalColor=get(button,'BackgroundColor');
set(button,'Callback',@stopWaiting,'BackgroundColor','r')
    function stopWaiting(src,~)
        stop(ReadTimer);
        arm(dig,'stop');
        set(src,'BackgroundColor',OriginalColor,...
            'String','Close','Callback',@done);
        set(status,'BackgroundColor','r',...
            'String','DISARMED');
        set(interval(end),'Enable','off');
        message=get(problem(end),'Data');
        message{end+1}='Acquisition stopped';
        set(problem(end),'Data',message); 
        SystemArmed=false;
        drawnow();
    end
    function done(src,~)
        set(src,'String','');
    end

autosave(1)=addblock(box,'text','',40);
autosave(2)=addblock(box,'text','',40);

arm(dig);
locate(box,'center');
box.Hidden=false;
box.Modal=true;

set(box.Handle,'CloseRequestFcn','');
    
%%
ReadTimer=timer('Period',period/10,...
    'ExecutionMode','fixedSpacing','TimerFcn',@readTimer);
TimerValue=0;
    function readTimer(varargin)
        TimerValue=TimerValue+0.1;
        if TimerValue >= 1
            drawTimer(1);
            testNow();            
            TimerValue=0;
        end
        drawTimer(TimerValue)
    end

pos=get(interval(1),'Position');
TimerBar=ones(round([pos(4) pos(3) 3]));
drawTimer(0);
    function drawTimer(value)
        if value == 0
            TimerBar(:)=1;
        elseif value == 1
            TimerBar(:,:,1)=0;
        else
            TimerBar(:,1:round(size(TimerBar,2)*TimerValue),1)=0;
        end
        set(interval(1),'CData',TimerBar);
    end
start(ReadTimer);

SystemArmed=true;
while SystemArmed
    pause(0.01);
end
try
    stop(ReadTimer);
catch    
end
waitfor(button,'String');
delete(box);
figure(master.Figure);

%%
h=findobj(master.Figure,'Type','uicontrol','String','Lock digitizers');
if ~get(h,'Value')
    unlock(dig);
end

end