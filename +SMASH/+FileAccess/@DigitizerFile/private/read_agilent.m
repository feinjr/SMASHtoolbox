function [signal,time]=read_agilent(filename,index)

% manage input
if (nargin<1) || isempty(filename)
    types={};
    types(end+1,:)={'*.h5;*.H5','Keysight HDF5 files'};
    types(end+1,:)={'*.*','All files'};
    [filename,pathname]=uigetfile(types,'Select Keysight data file');
    if isnumeric(filename) % user pressed cancel
        return
    end
    filename=fullfile(pathname,filename);
end

if (nargin<2) || isempty(index)
    index=1;
end

% verify index
report=probe_agilent(filename);
try
    report.Name=report.Name(index);
    report.GroupName=report.GroupName(index);
    report.DatasetName=report.DatasetName(index);
    report.NumberSignals=numel(index);
catch
    error('ERROR: invalid signal index');
end

% extract data
[signal,time]=deal(cell(numel(index),1));
for n=1:numel(index)
    % read attributes
    info=h5info(filename,report.GroupName{n});
    N=numel(info.Attributes);
    [name,value]=deal(cell(1,N));
    for k=1:N
        temp=info.Attributes(k);
        name{k}=temp.Name;
        value{k}=temp.Value;
    end
    attribute=cell2struct(value,name,2);
    % read/convert data
    signal{n}=h5read(filename,report.DatasetName{n});
    if isinteger(signal{n})
        signal{n}=double(signal{n});
        y0=double(attribute.YOrg);
        dy=double(attribute.YInc);
        signal{n}=y0+dy*signal{n};
    else
        signal{n}=double(signal{n}(:));
    end
    numpoints=double(attribute.NumPoints);
    dx=double(attribute.XInc);
    left=double(attribute.XOrg);
    right=left+(numpoints-1)*dx;
    time{n}=left:dx:right;
    time{n}=double(time{n}(:));
end

if numel(signal)==1
    signal=signal{1};
    time=time{1};
end

end