function fig=createDialog()

%% create dialog
fig=SMASH.MUI.Dialog;
fig.Name='FileBrowser';
fig.Hidden=true;
set(fig.Handle,'Tag','SMASH:FileBrowser');
setappdata(fig.Handle,'DialogObject',fig);

%% define variables
FileLocation='';
FileName='';
Format='';
Report=[];
Summary='';
Contents=[];
Details='';

%% create dialog blocks
%h=addblock(fig,'text','Interactive file browser',40);
%set(h,'FontWeight','bold');

button=addblock(fig,'button',{'Select file'});
set(button(1),'Callback',@selectFile);
    function selectFile(varargin)
        %%
        default=fullfile(FileLocation,FileName);
        [filename,pathname]=uigetfile('*.*','Select file',default);
        figure(fig.Handle);
        if isnumeric(filename)
            return;
        end
        FileName=filename;
        FileLocation=pathname;
        set(hLocation(end),'String',FileLocation);
        set(hName(end),'String',FileName);
        %%
        target=fullfile(FileLocation,FileName);        
        Format=SMASH.FileAccess.determineFormat(target);
        try
            Report=SMASH.FileAccess.probeFile(target,Format);
            
        catch
            Report=struct();
        end
        Summary=sprintf('This ''%s'' format file contains %d records.',...
            Format,numel(Report));
        set(hSummary(2),'String',Summary);
        %%
        N=numel(Report);
        Contents=cell(1,N);
        switch Format
            case 'column'
                
            case {'agilent','keysight'}
                
            case {'saturn','zdas'}
                
            case 'pff'
                for n=1:N
                    %Contents{n}=sprintf('Record %d : %s',n,Report(n).TypeLabel);
                    Contents{n}=sprintf('Record %d: %s',n,Report(n).Title);
                end
            case 'sda'
                
            otherwise
                Contents{1}='(unlabeled record)';
                set(hContents(3),'Enable','off');
        end                       
        set(hContents(2),'String',Contents,'Value',1,'Enable','on');        
        selectRecord;
        set(hDetail(2),'Enable','on');
    end

hLocation=addblock(fig,'edit','Location:',40);
set(hLocation(1),'FontWeight','bold');
set(hLocation(2),'Callback',@changeLocation)
    function changeLocation(varargin)
        set(hLocation(2),'String',FileLocation);
    end

hName=addblock(fig,'edit','Name:',40);
set(hName(1),'FontWeight','bold');
set(hName(2),'Callback',@changeName)
    function changeName(varargin)
        set(hName(2),'String',FileName);
    end

hSummary=addblock(fig,'edit','Summary:',40);
set(hSummary(1),'FontWeight','bold');
set(hSummary(2),'Callback',@changeSummary);
    function changeSummary(varargin)
        set(hSummary(2),'String',Summary);
    end

hContents=addblock(fig,'popup','Contents',{' '},40);
set(hContents(1),'FontWeight','bold');
set(hContents(2),'Enable','off','Callback',@selectRecord);
    function selectRecord(varargin)
        index=get(hContents(2),'Value');
        Details=processReport(Report(index));        
        %command=sprintf('display(Report(%d))',index);
        %Details=evalc(command);
        set(hDetail(2),'String',Details);
        %parent=msgbox(message,'Record details');
        %child=findobj(parent,'Type','text');
        %set(child,'FontName','fixed');
    end

hDetail=addblock(fig,'medit','Record details:',40,5);
set(hDetail(1),'FontWeight','bold');
set(hDetail(2),'Enable','off',...
    'Callback',@changeDetails);
    function changeDetails(varargin)
        set(hDetail(2),'String',Details);
    end

%hLoad=addblock(fig,'button',{'Generate commands'});

%% finalize dialog
locate(fig,'center');
fig.Hidden=false;
%set(fig.Handle,'HandleVisibility','callback');

end