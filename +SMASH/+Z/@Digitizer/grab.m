function result=grab(object)

% manage multiple digitizers
if numel(object) > 1
    result=cell(size(object));
    for n=1:numel(object)
        result{n}=grab(object(n));
    end
    return
end

% set byte order
fwrite(object.VISA,':WAVEFORM:BYTEORDER LSBFIRST'); % this is supposed to be faster
fclose(object.VISA);
object.VISA.ByteOrder='littleEndian';
fopen(object.VISA);

fwrite(object.VISA,':WAVEFORM:FORMAT WORD');
fwrite(object.VISA,'WAVEFORM:STREAMING 1');

% read data
N=4;
keep=false(1,N);
label=cell(1,N);
data=[];
time=[];
for n=1:N
    if ~object.Channel(n).Display
        continue        
    end    
    command=sprintf('WAVEFORM:SOURCE CHANNEL%d',n);
    fwrite(object.VISA,command);
    fwrite(object.VISA,'WAVEFORM:COMPLETE?');
    complete=fscanf(object.VISA,'%g',1);
    if complete == 0
        continue
    end    
    fwrite(object.VISA,'WAVEFORM:PREAMBLE?');
    preamble=fscanf(object.VISA);
    preamble=readPreamble(preamble);
    if isempty(time)
        tstop=preamble.XOrigin+preamble.XIncrement*(preamble.Points-1);
        time=preamble.XOrigin:preamble.XIncrement:tstop;
        data=nan(numel(time),N);
    end    
    keep(n)=true;
    %    
    fclose(object.VISA);
    object.VISA.InputBufferSize=2*preamble.Points;      
    fopen(object.VISA);
    %
    fwrite(object.VISA,'WAVEFORM:DATA?');
    start=fread(object.VISA,2,'uchar');
    start=char(reshape(start,[],numel(start)));
    assert(strcmp(start,'#0'),'ERROR: invalid stream start');
    temp=fread(object.VISA,[preamble.Points 1],'int16');
    temp=preamble.YOrigin+preamble.YIncrement*temp;
    data(:,n)=temp(:); %#ok<AGROW>
    fread(object.VISA,1,'uchar'); % termination character
    label{n}=sprintf('Channel %d',n);
end

if isempty(data)
    error('ERROR: no signals to grab');
else
    data=data(:,keep);
    label=label(keep);
    result=SMASH.SignalAnalysis.SignalGroup(time,data);
    result.GridLabel='Time (s)';
    result.DataLabel='Signal (V)';
    result.Precision='single';
    result.Legend=label;
    result.Name=object.Name;
    result.GraphicOptions.Title=object.Name;
end

end

function output=readPreamble(in)

output=struct();

[output.Mode,in]=nibble(in);
[output.Type,in]=nibble(in);
[output.Points,in]=nibble(in);
[output.Count,in]=nibble(in);

[output.XIncrement,in]=nibble(in);
[output.XOrigin,in]=nibble(in);
[output.XReference,in]=nibble(in);

[output.YIncrement,in]=nibble(in);
[output.YOrigin,in]=nibble(in);
[output.YReference,in]=nibble(in);

[output.Coupling,in]=nibble(in);

[output.XDisplayRange,in]=nibble(in);
[output.XDisplayOrigin,in]=nibble(in);
[output.YDisplayRange,in]=nibble(in);
[output.YDisplayOrigin,in]=nibble(in);

[output.Date,in]=nibble(in);
[output.Date,in]=nibble(in);
[output.FrameModel,in]=nibble(in);

[output.AcquisitionMode,in]=nibble(in);
[output.Completion,in]=nibble(in);

[output.XUnits,in]=nibble(in);
[output.YUnits,in]=nibble(in);

[output.MaxBandWidth,in]=nibble(in);
[output.MinBandWidth,~]=nibble(in);

end

function [value,text]=nibble(text)

if text(1)=='"'
    index=find(text=='"',2,'first');
    start=index(1)+1;
    stop=index(2)-1;
    value=text(start:stop);
    next=index(2)+1;
else
    [value,~,~,next]=sscanf(text,'%g',1);
end

text=text(next+1:end);

end