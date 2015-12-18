function DialogConnection(~,~,object)

dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='Measurement connections';

width=30;
addblock(dlg,'text','Experiment:',width);
addblock(dlg,'text',['   ' object.Experiment],width);

h=addblock(dlg,'table',...
    {'Probe' 'Diagnostic' 'Digitizer' 'Channel' 'Measurement'},...
    [5 5 5 5 20],10);
data=cell(object.MaxConnections,5);
for n=1:object.MaxConnections
    if n <= numel(object.MeasurementLabel)
        for m=1:4
            data{n,m}=sprintf('%d',object.MeasurementConnection(n,m));
        end
        data{n,5}=object.MeasurementLabel{n};
    else
        for m=1:5
            data{n,m}=' ';
        end
    end
end
set(h(end),'Data',data);

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
ColumnFormat{3}=cell(1,N+1);
ColumnFormat{3}{1}=' ';
for n=1:N
    ColumnFormat{3}{n+1}=sprintf('%d',object.Digitizer(n));
end
ColumnFormat{4}='char';
ColumnFormat{5}='char';
set(h(6),'ColumnFormat',ColumnFormat);

N=numel(object.Digitizer);
message=cell(1,N);
for n=1:N
    message{n}=[sprintf('Digitizer %d:',n) sprintf(' %d',object.DigitizerChannel{n})];   
end
message=sprintf('%s\n',message{:});
set(h(4),'TooltipString',message);

set(h(end),'CellEditCallback',@editTable)
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
        data=data{1};
        % complete test
        table=nan(object.MaxConnections,4);
        label=cell(object.MaxConnections,1);
        missing=zeros(object.MaxConnections,1);
        keep=true(object.MaxConnections,1);
        for nc=1:object.MaxConnections
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
                message{end+1}='     -Incomplete connection(s)';
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
                message{end+1}='     -Repeated connection(s)';
                break
            elseif any(table(nc,2)==table(m,2))
                message{end+1}='     -Repeated connection(s)';
                break
            elseif any((table(nc,3)==table(m,3)) & (table(nc,4)==table(m,4)))
                message{end+1}='     -Repeated connection(s)';;
                break
            end
        end        
        % valid test
        N=size(data,1);
        for nc=1:N
            if isnan(table(nc,1)) || any(table(nc,1)==object.Probe)
                % do nothing
            else
                message{end+1}=sprintf('     -Invalid connection(s)');
                break
            end
            if isnan(table(nc,2)) || any(table(nc,2)==object.Diagnostic)
                % do nothing
            else
                message{end+1}=sprintf('     -Invalid connection(s)');
                break
            end
            if isnan(table(nc,3)) || any(table(nc,3)==object.Digitizer)
                % do nothing
            else
                message{end+1}=sprintf('     -Invalid connection(s)');
                break
            end
            if isnan(table(nc,4)) || ...
                    any(table(nc,4)==object.DigitizerChannel{find(object.Digitizer==table(nc,3))})
                % do nothing
            else
                message{end+1}=sprintf('     -Invalid connection(s)');
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
            verifyConnection;
            return
        end
        keep=~any(isnan(table),2);        
        object.MeasurementConnection=table(keep,:);
        object.MeasurementLabel=label;        
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

end