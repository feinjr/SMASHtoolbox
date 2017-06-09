function runParanoid(master,dig,fontsize)

%%
set(master.Figure,'Visible','off');

box=SMASH.MUI.Dialog('FontSize',fontsize);
box.Hidden=true;
box.Name='Shot mode';

status=addblock(box,'text','FULLY ARMED',20);
set(status,'BackgroundColor','g','FontWeight','bold');

interval=addblock(box,'edit_button',{'Interval (sec):' ' Test now '});
period=5;
set(interval(2),'String',sprintf('%d',period),'UserData',period,...
    'Callback',@changeInterval)
    function changeInterval(src,~)      
        period=get(src,'UserData');
        new=sscanf(get(src,'String'),'%g',1);
        if isempty(new)
            period=max(ceil(new),2); % minimum of two seconds
        end        
        stop(ProbeTimer);
        ProbeTimer.Period=period;
        start(ProbeTimer);
        set(src,'String',sprintf('%d',period),'UserData',period);
    end
set(interval(3),'Callback',@testNow)
    function testNow(varargin)
        disp('Testing digitizer(s)');
        N=numel(dig);
        armed=false(N,1);
        message={};
        for n=1:N
            delay=SMASH.System.ping(dig(n).System.Address);
            if isnan(delay)
                message{end+1}=sprintf('%s is not responding',dig(n).Name); %#ok<AGROW>
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
            stop(ProbeTimer);
            set(status,'String','Disarmed','BackgroundColor','r');
        else           
            index=find(~armed);
            for n=1:numel(index)
                message{end+1}=sprintf('%s triggered',dig(n).Name); %#ok<AGROW>
            end
            set(status,'String','Partially armed','BackgroundColor','y');
        end
        set(problem(end),'Data',message);
    end

problem=addblock(box,'table',{'Report:'},30,5);
set(problem(end),'ColumnEditable',false,'Data',{});

button=addblock(box,'button',' STOP ');
OriginalColor=get(button,'BackgroundColor');
set(button,'Callback',@stop,'BackgroundColor','r')
    function stop(src,~)
        set(src,'BackgroundColor',OriginalColor,...
            'String','Close','Callback',@done);
        set(status,'BackgroundColor','r',...
            'String','DISARMED');
        set(interval(end),'Enable','off');
        data=get(problem(end),'Data');
        data{end+1}='Acquisition stopped';
        set(problem(end),'Data',data);        
    end
    function done(varargin)
        delete(box);
    end

arm(dig);
locate(box,'center');
box.Hidden=false;
%box.Modal=true;

set(box.Handle,'CloseRequestFcn','');

%% set up timer
ProbeTimer=timer();
ProbeTimer.StartDelay=0;
ProbeTimer.Period=period;
ProbeTimer.TimerFcn=@testNow;
ProbeTimer.ExecutionMode='fixedSpacing';
start(ProbeTimer);
    
%%
waitfor(button,'String');
figure(master.Figure);
stop(ProbeTimer);

end