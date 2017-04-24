function setAcquisition(object,value)

% manage input
assert(isstruct(value),'ERROR: invalid acquisition setting');

% apply settings
communicate(object);

%
temp=value.SampleRate;
assert(isnumeric(temp) && isscalar(temp) && (temp>0),...
    'ERROR: invalid sample rate');
command=sprintf('ACQUIRE:SRATE:ANALOG %g',temp);
fwrite(object.VISA,command);

assert(isnumeric(temp) && isscalar(temp) && (temp>=0),...
    'ERROR: invalid number of averages');
%
temp=value.NumberPoints;
assert(isnumeric(temp) && isscalar(temp) && (temp>0),...
    'ERROR: invalid number of points');
command=sprintf('ACQUIRE:POINTS:ANALOG %d',temp);
fwrite(object.VISA,command);

%
temp=value.NumberAverages;
if temp < 2
    fwrite(object.VISA,'ACQUIRE:AVERAGE OFF');
else
    fwrite(object.VISA,'ACQUIRE:AVERAGE ON');
    command=sprintf('ACQUIRE:AVERAGE:COUNT %d',temp);
    fwrite(object.VISA,command);
    
end

end