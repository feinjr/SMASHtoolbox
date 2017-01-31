% grabSignal Grab signal(s) from ZDAS
%
% This function grabs Data Acquisition System (DAS) signals from Z
% experiments.  Signals can be grabbed from a local file:
%    object=grabSignal(filename,label1,label2,...);
% or from the local network.
%    object=grabSignal(shotnumber,label1,label2,...); % integer ID
% The output is a SignalGroup object generated from the specified label(s).
%  Wild cards, such as '*PSB*', are permitted in the labels.
% 
% The default access point for network files is the raw PFF data stored on
% the york server.  The same information can also be accessed in HDF
% format.
%    object=grabSignal(shotnumber,'-hdf',label); % use *.hdf archive
%    object=grabSignal(shotnumber,'-pff',label); % use *.pff archive (default)
% Network files are temporarily copied from the network to the local
% machine, so it is faster to grab several signals at once rather than
% calling this function for individual signals.  
%
% An additional flag can be specified to access the processed machine
% current files instead of the raw signals.
%    object=grabSignal(shotnumber,'-hdf','-jkmoore',label);
%    object=grabSignal(shotnumber,'-tcwagon',label);
%
% Calling this function with no output copies a network file to the local machine.
%    grabSignal(shotnumber); % copy raw *.pff
%    grabSignal(shotnumber,'-jkmoore'); % copy processed *.pff file  
%    grabSignal(shotnumber,'-hdf'); % copy raw *.hdf file 
%
% See also Z, SMASH.Signal.SignalGroup
% 

%
% created January 29, 2016 by Daniel Dolan (Sandia National Laboratories)
% updated February 25, 2016 by Daniel Dolan
%    -added copy-only mode
% updated January 30, 2017 by Daniel Dolan
%    -transitioned from sasn898 to york server
%    -refined option handling to support processed machine current files
%
function varargout=grabSignal(varargin)

% manage input
assert(nargin >= 1,'ERROR: insufficient input');

if isnumeric(varargin{1})
    assert(SMASH.General.testNumber(varargin{1},'positive','integer'),...
        'ERROR: invalid shot number');    
    object=grabRemote(nargout,varargin{:});
elseif ischar(varargin{1})
    assert(exist(varargin{1},'file')==2,'ERROR: file not found');
    object=grabLocal(varargin{:});
else
    error('ERROR: invalid input');
end

% manage output
if nargout==0
    if ~isempty(object)
        view(object);
    end
else
    varargout{1}=object;
end

end

function object=grabRemote(Nout,shot,varargin)

% manage input
subdir='pff_data';
extension='.pff';
type='raw';

Narg=numel(varargin);
label={};
for n=1:Narg
    if varargin{n}(1)=='-'
        switch lower(varargin{n})
            case '-pff'
                subdir='pff_data';
                extension='.pff';
            case '-hdf'
                subdir='hdf_data';
                extension='.hdf';
            case '-jkmoore'
                type='jkmoore';
            case '-tcwagon'
                type='tcwagon';
            otherwise
                error('ERROR: invalid option');
        end
    else
        label{end+1}=varargin{n}; %#ok<AGROW>
    end
end
assert(iscellstr(label),'ERROR: invalid signal label(s)');

% copy remote file to a temporary local file

switch type
    case 'raw'
        sourcefile=sprintf('pbfa2z_%d%s',shot,extension);
        sourcefile=fullfile(subdir,'pbfa2z',sourcefile);
    case {'jkmoore' 'tcwagon'}
        sourcefile=sprintf('z%d_%s%s',shot,type,extension);
        sourcefile=fullfile(subdir,'scratch',sourcefile);
end

[~,tempfile,ext]=fileparts(sourcefile);
tempfile=sprintf('.tempfile_%s%s',tempfile,ext);

if ispc
    %sourcefile=fullfile('\\sasn898',subdir,'pbfa2z',sourcefile);
    sourcefile=fullfile('\\york',subdir,'pbfa2z',sourcefile);
    copyfile(sourcefile,tempfile,'f');
else
    %sourcefile=fullfile('sasn898:',subdir,'pbfa2z',sourcefile);
    commandwindow;
    command=sprintf('scp "york:/%s" "%s"',sourcefile,tempfile);
    system(command,'-echo');
end
assert(exist(tempfile,'file')==2,'ERROR: requested file not found');


if Nout==0 % copy only mode
    final=tempfile(11:end);
    if exist(final,'file')
        fprintf('Overwrite exisiting file?\n');
        result=input('   (y)es or [no]: ','s');
        switch result
            case {'y','yes'}
                delete(final);
        end
    end
    movefile(tempfile,final,'f')
    object=[];
else % read signals and delete temporary local file
    object=grabLocal(tempfile,label{:});
    delete(tempfile);
end

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