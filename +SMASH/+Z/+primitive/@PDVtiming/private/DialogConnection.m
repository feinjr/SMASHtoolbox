function DialogConnection(~,~,object)

dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='Measurement connections';

width=30;
addblock(dlg,'text','Experiment:',width);
addblock(dlg,'text',['   ' object.Experiment],width);

MaxConnections=object.MaxConnections;
data={};
hMaxConnect=addblock(dlg,'edit_button',{'Max. connections:',' Apply '});
value=sprintf('%d',object.MaxConnections);
set(hMaxConnect(2),'Callback',@readEditInteger,'String',value,'UserData',value);
set(hMaxConnect(3),'Callback',@applyMaxConnections);
    function applyMaxConnections(varargin)               
        MaxConnections=sscanf(get(hMaxConnect(2),'String'),'%d');
        data=get(hTable(end),'Data');            
        %
        if InitializeData
            M=numel(object.MeasurementLabel);
            data=cell(M,5);
            for mm=1:M
                for nn=1:4
                    data{mm,nn}=sprintf('%d',object.MeasurementConnection(mm,nn));
                end
                data{mm,5}=object.MeasurementLabel{mm};
            end         
            InitializeData=false;
        end        
        Mdata=size(data,1);
        if Mdata < MaxConnections
            data{MaxConnections,5}='';
             for mm=(Mdata+1):MaxConnections
                for nn=1:5
                    data{mm,nn}=' ';
                end
             end
        elseif Mdata > MaxConnections
            LastEntry=nan;
            for mm=1:Mdata
                temp=data(mm,:);
                temp=strtrim(sprintf('%s ',temp{:}));
                if ~isempty(temp)
                    LastEntry=mm;
                end
            end
            if LastEntry>MaxConnections
                choice=questdlg('This setting will drop connection input',...
                    'Drop inputs?',' Proceed ',' Cancel ',' Cancel ');
                choice=strtrim(choice);
                if strcmpi(choice,'proceed')
                    % continue
                else
                    value=size(get(hTable(end),'Data'),1);
                    set(hMaxConnect(2),'String',value,'UserData',value);
                    return
                end           
            end
            data=data(1:MaxConnections,:);
        end                  
        set(hTable(end),'Data',data);
    end

hTable=addblock(dlg,'table',...
    {'Probe' 'Diagnostic' 'Digitizer' 'Channel' 'Measurement'},...
    [5 5 5 5 20],10);
InitializeData=true;
applyMaxConnections();

ColumnFormat=cell(1,5);
N=numel(object.Probe);
ColumnFormat{1}=cell(1,N+1);
ColumnFormat{1}{1}=' ';
for n=1:N
    ColumnFormat{1}{n+1}=sprintf('%d',object.Probe(n));
end
N=numel(object.Diagnostic);
ColumnFormat{2}=cell(1,N+1);
ColumnFormat{2}{1}=' ';
for n=1:N
    ColumnFormat{2}{n+1}=sprintf('%d',object.Diagnostic(n));
end
N=numel(object.Digitizer);
channel=[];
ColumnFormat{3}=cell(1,N+1);
ColumnFormat{3}{1}=' ';
for n=1:N
    ColumnFormat{3}{n+1}=sprintf('%d',object.Digitizer(n));
    channel=[channel object.DigitizerChannel{n}(:)]; %#ok<AGROW>
end
channel=unique(channel);
N=numel(channel);
ColumnFormat{4}=cell(1,N+1);
ColumnFormat{4}{1}=' ';
for n=1:N
    ColumnFormat{4}{n+1}=sprintf('%d',channel(n));
end
ColumnFormat{5}='char';
set(hTable(6),'ColumnFormat',ColumnFormat);

set(hTable(end),'CellEditCallback',@editTable)
    function editTable(src,eventdata)
        row=eventdata.Indices(1);
        column=eventdata.Indices(2);            
        data=get(src,'Data');
        value=eventdata.EditData;       
        data{row,column}=value;
        set(src,'Data',data);
    end

h=addblock(dlg,'Button','Verify connections ');
set(h,'Callback',@verifyConnections);
    function varargout=verifyConnections(varargin)
        message={'Connection problem(s) detected:'};
        data=probe(dlg);
        data=data{2};       
        % complete test
        table=nan(MaxConnections,4);
        label=cell(MaxConnections,1);
        missing=zeros(MaxConnections,1);
        keep=true(MaxConnections,1);
        for nc=1:MaxConnections
            for k=1:4
                temp=sscanf(data{nc,k},'%d');
                if isempty(temp)
                   missing(nc)=missing(nc)+1;
                else
                    table(nc,k)=temp;
                end
            end
            temp=strtrim(data{nc,end});
            if isempty(temp)
                missing(nc)=missing(nc)+1;
            else
                label{nc}=temp;
            end
            if missing(nc)==0
                for k=1:4
                    data{nc,k}=data{nc,k};
                    label{nc}=data{nc,end};
                end                
            elseif (missing(nc)==5)
                keep(nc)=false;
            else
                message{end+1}='     -Incomplete connection(s)'; %#ok<AGROW>
                break
            end           
        end
        data=data(keep,:);
        label=label(keep);
        % unique test
        N=size(data,1);        
        for nc=1:N
            m=[1:(nc-1) (nc+1):N];
            if any(table(nc,1)==table(m,1))
                message{end+1}='     -Repeated connection(s)'; %#ok<AGROW>
                break
            elseif any(table(nc,2)==table(m,2))
                message{end+1}='     -Repeated connection(s)'; %#ok<AGROW>
                break
            elseif any((table(nc,3)==table(m,3)) & (table(nc,4)==table(m,4)))
                message{end+1}='     -Repeated connection(s)'; %#ok<AGROW>
                break
            end
        end        
        % valid test
        N=size(data,1);
        for nc=1:N
            if isnan(table(nc,1)) || any(table(nc,1)==object.Probe)
                % do nothing
            else
                message{end+1}=sprintf('     -Invalid connection(s)'); %#ok<AGROW>
                break
            end
            if isnan(table(nc,2)) || any(table(nc,2)==object.Diagnostic)
                % do nothing
            else
                message{end+1}=sprintf('     -Invalid connection(s)'); %#ok<AGROW>
                break
            end
            if isnan(table(nc,3)) || any(table(nc,3)==object.Digitizer)
                % do nothing
            else
                message{end+1}=sprintf('     -Invalid connection(s)'); %#ok<AGROW>
                break
            end
            if isnan(table(nc,4)) || ...
                    any(table(nc,4)==object.DigitizerChannel{find(object.Digitizer==table(nc,3))})
                % do nothing
            else
                message{end+1}=sprintf('     -Invalid connection(s)'); %#ok<AGROW>
                break
            end
        end
        % report problems
        if numel(message)==1
            flag=true;
        else
            message=sprintf('%s\n',message{:});
            errordlg(message,'Connection problem(s)');
            flag=false;
        end
        % manage output
        if (nargout==0) && flag
            msgbox('No connection problems found','Connections verified');
        else
            varargout{1}=flag;
            varargout{2}=table;
            varargout{3}=label;
        end
    end

h=addblock(dlg,'Button',{' Done ' ' Cancel '});
set(h(1),'Callback',@done)
    function done(varargin)
        [flag,table,label]=verifyConnections;
        if ~flag
            verifyConnections;
            return
        end
        keep=~any(isnan(table),2);        
        object.MeasurementConnection=table(keep,:);
        object.MeasurementLabel=label;        
        object.MaxConnections=MaxConnections;
        delete(dlg);
    end
set(h(2),'Callback',@cancel);
    function cancel(varargin)   
        delete(dlg);
    end


locate(dlg,'center',object.DialogHandle);
dlg.Hidden=false;
dlg.Modal=true;
uiwait(dlg.Handle);

figure(object.DialogHandle);

end