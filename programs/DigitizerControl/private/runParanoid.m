function runParanoid(master,dig,fontsize)

%%
clearDisplay(dig);
lock(dig);

%%
set(master.Figure,'Visible','off');

box=SMASH.MUI.Dialog('FontSize',fontsize);
box.Hidden=true;
box.Name='Shot mode';

status=addblock(box,'text','FULLY ARMED',20);
set(status,'BackgroundColor','g','FontWeight','bold');

interval=addblock(box,'edit_button',{'Trigger query (sec):' ' Read '});
period=5;
set(interval(2),'String',sprintf('%d',period),'UserData',period,...
    'Callback',@changeInterval)
    function changeInterval(src,~)       
        new=sscanf(get(src,'String'),'%g',1);
        if isempty(new)
            new=get(src,'UserData');
        end        
        new=max(ceil(new),1); % minimum of one second       
        set(src,'String',sprintf('%d',new),'UserData',new);
        stop(ReadTimer);
        ReadTimer.Period=new/10;
        drawTimer(0);
        start(ReadTimer);
    end
set(interval(3),'Callback',@testNow)
testMessage={};
    function testNow(varargin)
        WorkingButton(interval(3));
        C=onCleanup(@() WorkingButton(interval(3)));
        N=numel(dig);
        armed=false(N,1);        
        for n=1:N
            delay=SMASH.System.ping(dig(n).System.Address);
            if isnan(delay)
                testMessage{end+1}=sprintf('%s is not responding',dig(n).Name); %#ok<AGROW>
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
        else           
            index=find(~armed);
            for n=1:numel(index)
                testMessage{end+1}=sprintf('%s disarmed',dig(n).Name); %#ok<AGROW>
            end
            set(status,'String','Partially armed','BackgroundColor','y');
        end
        set(problem(end),'Data',testMessage);
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

arm(dig);
locate(box,'center');
box.Hidden=false;
box.Modal=true;

set(box.Handle,'CloseRequestFcn','');
    
%%
ReadTimer=timer('Period',get(interval(2),'UserData')/10,...
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

pos=get(interval(3),'Position');
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
        set(interval(3),'CData',TimerBar);
    end
start(ReadTimer);

SystemArmed=true;
while SystemArmed
    pause(0.1);
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