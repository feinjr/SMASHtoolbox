% READ Read file associated with a DigitizerFile object
%
% Syntax:
%    >> output=read(object,[option]);
% The option input is only used for 'agilent' format files containing more
% than one signal.  The output is a structure with the following fields.
%    -FileName
%    -FileType
%    -FileOption
%    -Header
%    -Time
%    -Signal
%
% This method reads the file specified in a Digitizer object:
%    >> output=read(object);
% and returns the results in a structure.  A second input can be passed to
% select a specific signal in multi-signal formats (such as 'agilent').
%    >> output=read(object,record);
% If the output is omitted ...
%
% See also DigitizerFile, probe
%

%
function output=read(object,record)

% handle input
if nargin<2
    record=[];
end

% error checking
assert(exist(object.FullName,'file')==2,...
    'ERROR: cannot read file because it does not exist');

% call the appropriate reader
output.FileName=object.FullName;
output.Format=object.Format;
output.FileOption=record;
switch object.Format
    case 'agilent'
        report=probe(object);
        if isempty(record)
            if report.NumberSignals==1
                record=1;
            else
                [record,ok]=listdlg(...
                    'PromptString','Select signal',...
                    'Name','Select signal',...
                    'ListString',report.Name,...
                    'SelectionMode','single');
                if ~ok % user pressed cancel or closed the dialog
                    error('ERROR: no signal selected');
                end
            end
        elseif ~any(record==(1:report.NumberSignals))
            error('ERROR: invalid record number ');
        end        
        output.FileOption=record;
        [signal,time]=read_agilent(object.FullName,record);
    case 'keysight'
        report=probe(object);
        if isempty(record)
            if report.NumberSignals==1
                record=1;
            else
                [record,ok]=listdlg(...
                    'PromptString','Select signal',...
                    'Name','Select signal',...
                    'ListString',report.Name,...
                    'SelectionMode','single');
                if ~ok % user pressed cancel or closed the dialog
                    error('ERROR: no signal selected');
                end
            end
        elseif ~any(record==(1:report.NumberSignals))
            error('ERROR: invalid record number ');
        end        
        output.FileOption=record;
        [signal,time]=read_keysight(object.FullName,record);        
    case 'lecroy'
        [signal,time]=read_lecroy(object.FullName);
    case 'tektronix'
        [~,~,ext]=fileparts(object.FullName);
        switch ext
            case '.wfm'
                [signal,time]=read_tektronixWFM(object.FullName);
            case '.isf'
                [signal,time]=read_tektronixISF(object.FullName);
        end
    case 'yokogawa'
        [signal,time]=read_yokogawa(object.FullName);
    case 'zdas'
        [signal,time]=read_zdas(object.FullName,record);
    case 'saturn'
        [signal,time]=read_saturn(object.FullName);
    otherwise
        error('ERROR: requested format is not supported');
end
output.Time=time;
output.Signal=signal;


end