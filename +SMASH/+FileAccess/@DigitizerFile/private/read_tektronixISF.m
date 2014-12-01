function varargout=read_tektronixISF(filename)

if (nargin<1) || isempty(filename)
    [fname,pname]=uigetfile('*.isf;*.ISF','Choose Tektronix ISF file');
    if isnumeric(fname)
        return
    end
    filename=[pname fname];
end

% open file
fid=fopen(filename,'r');

% skip :WFMPRE: entry
fscanf(fid,'%8c',1);

% read ASCII header
header='';
while true
    temp=fscanf(fid,'%1c',1);
    if strcmp(temp,':')
        break
    end
    header(end+1)=temp;
end

% skip the CURVE entry
while true
    temp=fscanf(fid,'%1c',1);
    if strcmp(temp,'#')
        break
    end
end
temp=fscanf(fid,'%1c',1);
temp=sscanf(temp,'%d');
format=sprintf('%%%dc',temp);
fscanf(fid,format,1);

% process header
temp=header;
header=struct;
while numel(temp)>0
    [local,temp]=strtok(temp,';');
    [name,value]=strtok(local);
    value=strtrim(value);
    new=sscanf(value,'%g',1);
    if value(1)=='"' % remove extra quotes
        value=value(2:end-1);
    elseif ~isempty(new)
        value=new;
    end
    header.(name)=value;
    temp=strtrim(temp(2:end));
end

% read data
switch header.BIT_NR
    case 8
        precision='int8';
    case 16
        precision='int16';
    otherwise
        error('ERROR: unrecognized number of bits specified');
end
 
switch header.BYT_OR
    case 'LSB'
        machineformat='ieee-le';
    case 'MSB'
        machineformat='ieee-be';
    otherwise
        error('ERROR: unrecognized bit order specified');
end

skip=0;
numpoints=header.NR_PT;
data.y=fread(fid,numpoints,precision,skip,machineformat);
fclose(fid);

% define time axis
x1=header.XZERO;
dx=header.XINCR;
x2=x1+(numpoints-1)*dx;
data.x=x1:dx:x2;

% scale vertical axis
y0=header.YOFF;
scale=header.YMULT;
%data.y=scale*(data.y-y0);
data.y=scale*(data.y-y0)+header.YZERO;

% handle output
if nargout==0
    figure;
    plot(data.x,data.y);
end

if nargout>=1
    varargout{1}=data;
end

if nargout>=2
    varargout{2}=header;
end

