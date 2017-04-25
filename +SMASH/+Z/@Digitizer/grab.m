function result=grab(object)

fwrite(obj,':WAVEFORM:PREAMBLE?');
preamble=readPreamble(fscanf(obj,'%s'));
 
% set up time base
tstop=preamble.XOrigin+preamble.XIncrement*(preamble.Points-1);
time=preamble.XOrigin:preamble.XIncrement:tstop;
 
% read data
N=4;
keep=false(1,N);
data=nan(preamble.Points,N);
label=cell(1,N);
for n=1:N
    if ~object.Channel(n).Display
        continue
    end
    keep(n)=true;
    command=sprintf('WAVEFORM:SOURCE %d',n);
    fwrite(object.VISA,command);
    %
    fwrite(object.VISA,':WAVEFORM:BYTEORDER LSBFIRST'); % this is supposed to be faster than MSBF
    fclose(object.VISA);
    object.VISA.InputBufferSize=2*preamble.Points;
    object.VISA.ByteOrder='littleEndian';    
    fopen(object.VISA);
    fwrite(object.VISA,'WAVEFORM:DATA');
    temp=fread(object.VISA,[preamble.Points 1],'int16');
    temp=preamble.YOrigin+preamble.YIncrement*temp;
    data(:,n)=temp(:);
    label{n}=object.Channel(n).Label;
end

data=data(:,keep);
label=label(keep);
result=SMASH.SignalAnalysis.SignalGroup(time,data);
result.Legend=label;

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