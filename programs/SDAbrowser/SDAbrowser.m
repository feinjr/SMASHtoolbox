% UNDER CONSTRUCTION
function varargout=SDAbrowser()

if isdeployed
    varargout{1}=0;
end

%% create dialog
object=SMASH.MUI.Dialog();
object.Hidden=true;
object.Name='SDA browser (UNDER CONSTRUCTION)';
local=[]; % SDAfile object (created by loadFile callback, used everywhere)

%% file blocks
FileTitle=addblock(object,'text','Sandia Data Archive (SDA) file');
set(FileTitle,'FontWeight','bold');

File=addblock(object,'edit','File name:',50);

FileButton=addblock(object,'button',{' Select ',' Load ',' Create '});
set(FileButton(3),'Enable','off');

gap=addblock(object,'text',' ',40); % extra gap
delete(gap);

Date=addblock(object,'text','Created ?, updated ? (version ?) ',50);
set(Date,'Enable','off');

%Updated=addblock(object,'text','Updated: ',40);
%set(Updated,'Enable','off');

%Version=addblock(object,'text','Format version: ',40);
%set(Version,'Enable','off');

Writable=addblock(object,'checkbox','Writable');
set(Writable,'Enable','off','Callback',@setWritable);
    function setWritable(varargin)
        if get(Writable,'Value')
            local.Writable='yes';
        else
            local.Writable='no';
        end
    end

gap=addblock(object,'text',' ',40); % extra gap
delete(gap);

box(object,[FileTitle File FileButton Writable]);

%% existing record blocks
RecordTitle=addblock(object,'text','Archive contains 0 records');
set(RecordTitle,'FontWeight','bold');

Record=addblock(object,'popup_button',{'Record label:' ' New '},{' '},40);
set(Record(2:3),'Enable','off');
RecordButton=addblock(object,'button',{' View ' ' Extract ' ' Export ' 'Delete'});
set(RecordButton,'Enable','off')

gap=addblock(object,'text',' ',40); % extra gap
delete(gap);

Type=addblock(object,'text','Type: ',40);

Description=addblock(object,'medit','Description:',50,2);
Update=addblock(object,'button',' Save description');
set(Update,'Enable','off');

%Utility=addblock(object,'button',{'Add record' 'Delete record'},20);
%set(Utility(2),'Enable','off');

box(object,[RecordTitle Record RecordButton Type Description Update]);

%% done button
Done=addblock(object,'button',' Done ');
set(Done,'Callback',@done);
    function done(varargin)
        delete(object);
    end

%% compound callbacks
set(FileButton(1),'Callback',@selectFile)
    function selectFile(varargin)
        [filename,pathname]=uigetfile('*.sda','Select archive file');
        if isnumeric(filename)
            return
        end
        set(File(end),'String',fullfile(pathname,filename));
    end

set(FileButton(2),'Callback',@loadFile)
    function loadFile(varargin)
        filename=get(File(end),'String');
        if isempty(filename)
            selectFile()
            filename=get(File(end),'String');
            if isempty(filename);
                return
            end
        end
        target=get(File(end),'String');
        [~,~,ext]=fileparts(target);
        if ~strcmpi(ext,'.sda')
            errordlg('Invalid file extension','File error','modal');
            return
        end
        try
            local=SMASH.FileAccess.SDAfile(target);
        catch
            errordlg('Unable to load file','File error','modal');
            return
        end
        [label,~,~,status]=probe(local);
        if isempty(status)
            set(Date,'String','Created ? , updated ? (version ?)',Enable','off');   
            %set(Version,'String','Format: ','Enable','off');
            set(Writable,'Enable','off');
        else
            set(Date,...
                'String',sprintf('Created %s, updated %s (version. %s)',status.Created,status.Updated,status.FormatVersion),...
                'Enable','on');           
            %set(Version,'String',['Format version: ' status.FormatVersion],'Enable','on');      
            if strcmpi(status.Writable,'yes')
                set(Writable,'Value',1,'Enable','on');
            else
                set(Writable,'Value',0,'Enable','on');
            end
        end
        set(Record(2),'Value',1);
        set(RecordTitle,'String',...
            sprintf('Archive contains %d records',numel(label)));
        selectRecord();
    end

set(Record(2),'Callback',@selectRecord)
    function selectRecord(varargin)
        [label,type,description]=probe(local);
        if numel(label) > 0
            set(Record(2),'String',label,'Enable','on');
            value=get(Record(2),'Value');
            type=type{value};
            switch lower(type)
                case 'object'
                    try
                    source=h5readatt(local.ArchiveFile,['/' label{value}],'Class');
                    catch
                        source=h5readatt(local.ArchiveFile,['/' label{value}],'ClassName');
                    end
                    set(Type,'String',['Type: ' source ' object' ],'Enable','on');
                    set(RecordButton(1:2),'Enable','on');
                    set(RecordButton(3),'Enable','off');
                case 'file'
                    set(Type,'String',['Type: ' type ],'Enable','on');
                    set(RecordButton(1:2),'Enable','off');
                    set(RecordButton(3),'Enable','on');
                otherwise
                    set(Type,'String',['Type: ' type ],'Enable','on');
                    set(RecordButton(2),'Enable','on');
                    set(RecordButton([1 3]),'Enable','off');
            end
            set(Description(end),'String',description{value});
            set(Update,'Enable','on');
        else
            set(Record,'String','','Enable','off');
            set(RecordButton,'Enable','off');
            set(Update,'Enable','off');
        end
    end

set(RecordButton(1),'Callback',@viewRecord);
    function viewRecord(varargin)
        value=get(Record(2),'Value');
        label=get(Record(2),'String');
        previous=extract(local,label{value});
        view(previous);
    end

set(RecordButton(2),'Callback',@extractRecord);
    function extractRecord(varargin)
        answer=inputdlg({'Variable for extracted record'},...
            'Choose variable',1,{'PreviousObject'});       
        if isempty(answer)
            return
        elseif ~isvarname(answer{1})
            errordlg('Invalid variable name','Invalid name')
            extractRecord();
        end        
        value=get(Record(2),'Value');
        label=get(Record(2),'String');
        previous=extract(local,label{value});
        assignin('base',answer{1},previous);
    end

set(RecordButton(3),'Callback',@exportRecord);
    function exportRecord(varargin)
        value=get(Record(2),'Value');
        label=get(Record(2),'String');
        target=fullfile(pwd,label{value});
        [~,~,ext]=fileparts(target);
        [filename,pathname]=uiputfile(ext,'Select export file',target);
        if isnumeric(filename)
            return
        end
        export(local,label{value},fullfile(pathname,filename));
    end

%% display dialog
set(object.Handle,'HandleVisibility','callback');
locate(object,'center');
object.Hidden=false;

end