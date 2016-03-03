% loadSession Load timing information from a session file
%
% This method is meant for use in the constructor only!
%

%
% created December 15, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function loadSession(object,filename)

% manage input
if (nargin<2) || isempty(filename)
    [filename,pathname]=uigetfile('*.*','Select session file');
    if isnumeric(filename)
        return
    end
    filename=fullfile(pathname,filename);
    object.SessionFile=filename;
end

% open session file
assert(ischar(filename) && (exist(filename,'file')==2),...
    'ERROR: invalid session file name');
try
    fid=fopen(filename,'r');
    CloseFile=onCleanup(@() fclose(fid));
catch
    error('ERROR: unable to read session file');
end

% process blocks
Experiment='';
Comment='';
Parameter=[];
MeasurementConnection=[];
MeasurementLabel={};
DigitizerTable=[];
DigitizerChannelTable=[];
DiagnosticTable=[];
ProbeTable=[];

while ~feof(fid)
    [name,content]=readBlock(fid);
    if isempty(name)
        continue
    end
    switch lower(name)
        case 'experiment:'            
            Experiment=strtrim(content{1});           
            Comment=content(2:end);            
        case 'connections:'
            content=content(2:end); % skip column labels
            [table,leftover]=scanColumns(content,5);
            MeasurementConnection=table(:,1:4); % drop correction column
            MeasurementLabel=leftover;                                                                                                                          
        case 'digitizer:'
            content=content(2:end); % skip column labels
            table=scanColumns(content,3);
            DigitizerTable=table;                                   
        case 'diagnostic:'
            content=content(2:end); % skip column labels
            table=scanColumns(content,2);
            DiagnosticTable=table;                    
        case 'probe:'
            content=content(2:end); % skip column labels
            table=scanColumns(content,2);
            ProbeTable=table;
        case 'parameters:'
            for n=1:numel(content)
                k=strfind(content{n},'=');
                name=sscanf(content{n}(1:k-1),'%s');
                value=sscanf(content{n}(k+1:end),'%g');
                Parameter.(name)=value;
            end
        case 'digitizer channels:'
            content=content(2:end); % skip column labels
            table=scanColumns(content,3);
            DigitizerChannelTable=table;            
        case 'obr reference:'
            content=content(2:end); % skip column labels
            table=scanColumns(content,2);
            OBRreferenceTable=table;           
        otherwise
            warning('SMASH:PDVtiming','unrecognized block name "%s"',name);
    end
end

% store results
if ~isempty(Experiment)
    object.Experiment=Experiment;
end
if ~isempty(Comment)
    width=0;
    N=numel(Comment);
    for n=1:N
        width=max(width,numel(Comment{n}));        
    end
    object.Comment=repmat(' ',[N width]);
    format=sprintf('%%-%ds',width);
    for n=1:N
        object.Comment(n,:)=sprintf(format,Comment{n});
    end    
end

if ~isempty(ProbeTable)
    setupProbe(object,ProbeTable(:,1),ProbeTable(:,2));
end

if ~isempty(DiagnosticTable)
    setupDiagnostic(object,DiagnosticTable(:,1),DiagnosticTable(:,2));
end

if ~isempty(DigitizerTable)
setupDigitizer(object,DigitizerTable(:,1),...
    DigitizerTable(:,2),DigitizerTable(:,3));
end

if ~isempty(DigitizerChannelTable)
    ND=numel(object.Digitizer);    
    index=cell(ND,1);
    delay=cell(ND,1);
    for n=1:size(DigitizerChannelTable,1)
        k=find(DigitizerChannelTable(n,1)==object.Digitizer);
        assert(~isempty(k),'ERROR: invalid digitizer index');
        index{k}(end+1)=DigitizerChannelTable(n,2);
        delay{k}(end+1)=DigitizerChannelTable(n,3);
    end
    setupDigitizerChannel(object,index,delay);
end

removeConnection(object,'all');
M=numel(MeasurementLabel);
object.MaxConnections=M;
for n=1:M
    addConnection(object,MeasurementConnection(n,:),MeasurementLabel{n});
end

if ~isempty(OBRreferenceTable)
    object.OBRreference=OBRreferenceTable;
end

if ~isempty(Parameter)
    name=fieldnames(Parameter);
    for n=1:numel(name)
        try
            object.(name{n})=Parameter.(name{n});
        catch
            warning('SMASH:PDVtiming',...
                'Unrecogized parameter "%s"',name{n});
        end
    end
end

end

%%
function [name,content]=readBlock(fid)

% read block name
name='';
while ~feof(fid)
    scan=fgetl(fid);
    if isempty(scan)
        continue
    end
    first=scan(1);
    scan=strtrim(scan);
    if isempty(scan) || strcmp(scan(1),first)
        name=scan;
        break   
    end
end

% read block contents
content={};
while ~feof(fid)
    scan=fgetl(fid);
    if isempty(scan)
        break
    end
    if isempty(strtrim(scan))
        if strcmp(scan(1),sprintf('\t'))
            scan=' ';
            % keep empty lines that begin with a tab (usually comment gaps)
        else
            break
        end
    else
        scan=strtrim(scan);
    end        
    content{end+1}=scan; %#ok<AGROW>
end

end

%%
function [table,leftover]=scanColumns(content,Ncolumn)

format=repmat('%g',[1 Ncolumn]);

Nrow=numel(content);
table=nan(Nrow,Ncolumn);
leftover=cell(size(content));
for m=1:Nrow    
    [temp,~,~,next]=sscanf(content{m},format,Ncolumn);
    table(m,:)=transpose(temp);
    leftover{m}=strtrim(content{m}(next:end));
end

end