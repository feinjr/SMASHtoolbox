function fig=CreateDialog()

%
fig=SMASH.MUI.Dialog;
fig.Name='FileBrowser';
fig.Hidden=true;

%
h=addblock(fig,'text','Interactive file browser',40);
set(h,'FontWeight','bold');

button=addblock(fig,'button',{'Select file','Refresh file'});
set(button(1),'Callback',@selectFile);
    function selectFile(varargin)
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
        refreshFile;
    end
set(button(2),'Callback',@refreshFile);
    function refreshFile(varargin)
        target=fullfile(FileLocation,FileName);
        Format=SMASH.FileAccess.determineFormat(target);
        set(hFormat(end),'String',Format);
        index=cellfun(@(a) strcmpi(Format,a),FormatList);
        set(hFormat(end),'ToolTipString',FormatDescription{index});
        try
            report=SMASH.FileAccess.probeFile(target,Format);
        catch
            report=struct();
        end
        set(hContents(2),'Value',1);
        processReport(report,hContents,Format);
    end

FileLocation='';
hLocation=addblock(fig,'edit','File location:',40);
set(hLocation(1),'FontWeight','bold');
set(hLocation(2),'Callback',@changeLocation)
    function changeLocation(varargin)
        set(hLocation(2),'String',FileLocation);
    end

FileName='';
hName=addblock(fig,'edit','File name:',20);
set(hName(1),'FontWeight','bold');
set(hName(2),'Callback',@changeName)
    function changeName(varargin)
        set(hName(2),'String',FileName);
    end

Format='';
hFormat=addblock(fig,'edit','Format:',20);
set(hFormat(1),'FontWeight','bold');
set(hFormat(2),'Callback',@changeFormat);
    function changeFormat(varargin)
        set(hFormat(2),'String',Format);
    end

[FormatList,FormatDescription]=SMASH.FileAccess.SupportedFormats;

hContents=addblock(fig,'popup_button',{'Contents:','Details'},{' '},40);
set(hContents(1),'FontWeight','bold');
set(hContents(2:3),'Enable','off');

%
locate(fig,'center');
fig.Hidden=false;

end

function processReport(report,hContents,format)

N=numel(report);
label=cell(1,N);
set(hContents(2),'Enable','on')
set(hContents(3),'Enable','off');
switch format
    case {'agilent','keysight'}
        
    case {'saturn','zdas'}
        
    case 'pff'
        for n=1:N
            label{n}=sprintf('%d : %s',n,report(n).TypeLabel);
        end
       set(hContents(3),'Enable','on') 
    case 'sda'
        set(hContents(3),'Enable','on')
    otherwise
        label={'(unlabeled record)'};
end
set(hContents(2),'String',label);

end