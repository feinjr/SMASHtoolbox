
function varargout=save(object)

% manage multiple digitizers
if numel(object) > 1
    for n=1:numel(object)
        save(object(n));
    end
    return
end

% single digitizer
command=sprintf('DISK:CDIRECTORY "%s"',object.RemoteDirectory.Location);
fwrite(object.VISA,command);
fwrite(object.VISA,'DISK:PWD?');
current=strtrim(fscanf(object.VISA));
assert(strcmpi(current,object.RemoteDirectory.Location),'ERROR: invalid save location');

filename=sprintf('%s.h5',object.Name);
command=sprintf('DISK:SAVE:WAVEFORM ALL, "%s" ,H5INT, ON',filename);
fwrite(object.VISA,command);

source=[repmat(filesep,[1 2]) object.System.Address filesep object.RemoteDirectory.ShareName filesep filename];

target=fullfile(pwd,filename);
% this command waits until copy actually finishes!
command=sprintf('powershell "copy %s %s | out-null"',source,target);
[status,result]=system(command);
if status ~= 0
    fprintf('%s\n',result);
    assert(false,'ERROR: unable to copy file');
end

command=sprintf('DISK:DELETE "%s"',filename);
fwrite(object.VISA,command);

if nargout > 0
    N=4;
    active=true(N,1);
    label=cell(N,1);
    temp=cell(N,1);
    k=0;
    % NOTE: non-signal records (functions, etc.) appear after signal
    for n=1:N
        if object.Channel(n).Display
            k=k+1;
            temp{n}=SMASH.SignalAnalysis.Signal(target,'keysight',k);
            label{n}=sprintf('Channel%d',n);
        else
            active(n)=false;
        end
    end
    temp=temp(active);
    varargout{1}=SMASH.SignalAnalysis.SignalGroup(temp{:});
    varargout{1}.Legend=label(active);
end

end