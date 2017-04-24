function result=grab(object)

% fwrite(obj,':WAVEFORM:PREAMBLE?');
% preamble=readPreamble(fscanf(obj,'%s'));
% 
% %% set up time base
% tstop=preamble.XOrigin+preamble.XIncrement*(preamble.Points-1);
% time=preamble.XOrigin:preamble.XIncrement:tstop;
% 
% %% read data
% fwrite(obj,':WAVEFORM:SOURCE 1');
% fprintf(obj,'%s',':WAVEFORM:SOURCE?');
% Source=fscanf(obj);
% 
% fwrite(obj,':WAVEFORM:BYTEORDER?');
% ByteOrder=strtrim(fscanf(obj));
% fwrite(obj,':WAVEFORM:BYTEORDER LSBFIRST'); % this is supposed to be faster
% 
% fclose(obj);
% obj.InputBufferSize=2*preamble.Points;
% switch lower(ByteOrder)
%     case 'msbf'
%         obj.ByteOrder='bigEndian';
%     case 'lsbf'
%         obj.ByteOrder='littleEndian';
% end
% fopen(obj);
% 
% fprintf('Reading data...');
% fprintf(obj,'%s',':WAVeform:DATA?');
% fprintf('done\n');
% data=fread(obj,[preamble.Points 1],'int16');
% data=preamble.YOrigin+preamble.YIncrement*data;


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
[output.MinBandWidth,in]=nibble(in);

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