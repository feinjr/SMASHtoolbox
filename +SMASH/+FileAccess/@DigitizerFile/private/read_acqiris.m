function [signal,time]=read_acqiris(filename,index)

% manage input
if (nargin<1) || isempty(filename)
    types={};
    types(end+1,:)={'*.h5;*.H5','Acqiris HDF5 files'};
    types(end+1,:)={'*.*','All files'};
    [filename,pathname]=uigetfile(types,'Select Acqiris data file');
    if isnumeric(filename) % user pressed cancel
        return
    end
    filename=fullfile(pathname,filename);
end

if (nargin<2) || isempty(index)
    index=1;
end

% read attributes
location=sprintf('/Waveforms/Channel %d',index);
name={'XInc' 'XOrg' 'YInc' 'YOrg'};
for n=1:numel(name)
    param.(name{n})=h5readatt(filename,location,name{n});
end

% read and convert data
location=sprintf('/Waveforms/Channel %d/Channel %dData',index,index);
signal=h5read(filename,location);
signal=param.YOrg+signal*param.YInc;
time=0:(numel(signal)-1);
time=param.XOrg+time*param.XInc;