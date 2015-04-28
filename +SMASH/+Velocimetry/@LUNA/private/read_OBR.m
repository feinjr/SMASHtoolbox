function data=read_OBR(filename)

fid=fopen(filename,'r','ieee-le');


% header
data.FormatVersion=fread(fid,1,'float32');
data.Descriptor=fread(fid,8,'char');
data.StartFrequency=fread(fid,1,'float64');
data.FrequencyIncrement=fread(fid,1,'float64');
data.StartTime=fread(fid,1,'float64');
data.TimeIncrement=fread(fid,1,'float64');
data.TimeIncrement=fread(fid,

% data


end