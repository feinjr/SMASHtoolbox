% grabSignal Grab DAS signal(s)
%
% This function grabs signals by name from a DAS file and returns data as a
% SignalGroup object.  Signals can be grabbed from a local file:
%    object=grabSignal(filename,label1,label2,...);
% or from the local network.
%    object=grabSignal(shotnumber,label1,label2,...);
% The shot number in the second example must be the integer ID for a
% particular experiment.  Wild cards are allowed in the signal label(s).
% 
% When accessing network files, this function defaults to the *.pff
% archive.  If for some reason these files are unavailable, the *.hdf
% archive can be used.
%    object=grabSignal(shotnumber,'hdf',...); % use *.hdf archive
%    object=grabSignal(shotnumber,'pff',...); % use *.pff archive (default)
% Archive files are temporarily copied from the network to the local
% machine, so it is faster to grab several signals at once rather than
% calling this function for individual signals.
%
% Calling this function with no record labels and no output copies the
% archive file (without reading it) to the local machine.
%    grabSignal(shotnumber); % copy *.pff archive
%    grabSignal(shotnumber,'pff'); % copy *.pff archive
%    grabSignal(shotnumber,'hdf'); % copy *.hdf archive
% Local archives are named "ZDAS" followed by the shot number and the
% extension *.pff/*.hdf.
% 
%
% See also Z, SMASH.Signal.SignalGroup
% 

%
% created January 29, 2016 by Daniel Dolan (Sandia National Laboratories)
% updated February 25, 2016 by Daniel Dolan
%    -added copy-only mode
%
function varargout=grabSignal(varargin)

% manage input
assert(nargin >= 1,'ERROR: insufficient input');

if (nargout==0) % copy-only mode
    if nargin<2
        varargin{2}='pff';
    end
    assert(strcmpi(varargin{2},'pff') || strcmpi(varargin{2},'hdf'),...
        'ERROR: invalid archive format');
else
    assert(nargin >= 2,'ERROR: insufficient input');
end

if isnumeric(varargin{1}) || isscalar(varargin{1})
    shot=varargin{1};       
    object=grabRemote(shot,varargin{2:end});
elseif ischar(varargin{1})
    file=varargin{1};
    if logical(exist(file,'file'))
        object=grabLocal(file,varargin{2:end});
    else
        shot=findNumber(file);
        assert(~isempty(shot),...
            'ERROR: unable to find requested file or extract shot number');
        commandwindow
        warning('SMASH:grabSignal','Unable to find requested file');
        fprintf('Look for shot %d on the remote server?\n',shot);
        answer=input('   (y)es or (n)o? : ','s');
        assert(strcmpi(answer,'y') || strcmpi(answer,'yes'),...
            'ERROR: no signals were grabbed');       
        try
            object=grabRemote(shot,varargin{2:end});
        catch
            error('ERROR: unable to find shot %d',shot);
        end
    end    
else
    error('ERROR: invalid input');
end

% manage output
if nargout==0
    if isempty(object)
        % do nothing
    else
        view(object);
    end
else
    varargout{1}=object;
end

end

function object=grabRemote(shot,varargin)

object=[];

CopyOnly=false;
if numel(varargin)==1
    if strcmpi(varargin{1},'pff') || strcmpi(varargin{1},'hdf')
        CopyOnly=true;
    end
end

% determine file extension
subdir='pff_data';
extension='.pff';
if strcmpi(varargin{1},'pff')
    varargin=varargin(2:end);
elseif strcmpi(varargin{1},'hdf')
    subdir='hdf_data';
    extension='.hdf';
    varargin=varargin(2:end);
end

assert(iscellstr(varargin),'ERROR: invalid signal label(s)');

if CopyOnly
    final=sprintf('ZDAS%d%s',shot,extension);
    if exist(final,'file')
        fprintf('Local archive found--overwrite exisiting file?\n');
        result=input('   (y)es or [no]: ','s');
        switch result
            case {'y','yes'}
                % continue
            otherwise
                return;
        end
    end
end

% copy remote file to a temporary local file
tempfile=sprintf('.tempfileZ%d%s',shot,extension);
tempfile=fullfile(pwd,tempfile);
sourcefile=sprintf('pbfa2z_%d%s',shot,extension);
if ispc
    sourcefile=fullfile('\\sasn898',subdir,'pbfa2z',sourcefile);
    copyfile(sourcefile,tempfile,'f');
else
    sourcefile=fullfile('sasn898:',subdir,'pbfa2z',sourcefile);
    commandwindow;
    command=sprintf('scp "%s" "%s"',sourcefile,tempfile);
    system(command);
end

if CopyOnly    
    movefile(tempfile,final,'f')
    return
end

% read signals and delete temporary local file
object=grabLocal(tempfile,varargin{:});
delete(tempfile);

end

function object=grabLocal(file,varargin)

assert(iscellstr(varargin),'ERROR: invalid signal label(s)');
Nlabel=numel(varargin);
found=zeros(1,Nlabel);

% find record matches
record={};
label={};
[~,~,extension]=fileparts(file);
switch extension
    case '.hdf'
        format='zdas';
        report=SMASH.FileAccess.probeFile(file,format);
        for n=1:report.NumberSignals
            temp=report.Names(n,:);
            temp=temp(double(temp)~=0);
            temp=strtrim(temp);
            for m=1:Nlabel
                if ismatch(temp,varargin{m})
                    record{end+1}=temp; %#ok<AGROW>
                    label{end+1}=temp; %#ok<AGROW>
                    found(m)=found(m)+1;
                    continue
                end                           
            end            
        end
    case '.pff'        
        format='pff';
        report=SMASH.FileAccess.probeFile(file,format);        
        for n=1:numel(report)
            temp=strtrim(report(n).Title);
            for m=1:Nlabel
                if ismatch(temp,varargin{m});
                    record{end+1}=n; %#ok<AGROW>
                    label{end+1}=temp; %#ok<AGROW>
                    found(m)=found(m)+1;
                    continue
                end
            end           
        end
end

for m=1:Nlabel
    if found(m)==0
        warning('SMASH:grabSignal','Signal "%s" not found',varargin{m});
    end
end

% read matching records
for n=1:numel(record)
    temp=SMASH.SignalAnalysis.SignalGroup(file,format,record{n});
    if n==1
        object=temp;
    else
        object=gather(object,temp);
    end           
end
object.Legend=label;

end

function result=ismatch(value,pattern)

pattern=regexptranslate('wildcard',pattern);
result=regexpi(value,pattern);

end

function shot=findNumber(label)

shot=[];

label=strtrim(label);
while numel(label)>0
    temp=sscanf(label,'%d',1);
    if isempty(temp)
        label=label(2:end);
    else
        shot=temp;
        break
    end
end

end