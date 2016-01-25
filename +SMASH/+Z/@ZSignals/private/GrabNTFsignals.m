function object = GrabNTFsignals(shot,detector,format)

switch detector
    case {'25 m', '25m', 'LOS50'}       
        SignalExp = 'NTF05[ABC]01MSH';
    case {'11 m', '11m','LOS270 rear'}
        SignalExp = 'NTF27[ABC]01MSH';
    case {'9 m', '9m','LOS270 front'}
        SignalExp = 'NTF27[ABC]02MSH';        
    case {'7 m', '7m','Bottom front'}
        SignalExp = 'NTFBT[ABC]01MSH';        
    case {'8 m', '8m','Bottom rear'}
        SignalExp = 'NTFBT[ABC]0[23]MSH';
    case '8 m 1'
        SignalExp = 'NTFBT[ABC]02MSH';        
    case '8 m 2'
        SignalExp = 'NTFBT[ABC]03MSH';        
end
switch format
    case '.pff'
        fileName = strcat('pbfa2z_',num2str(shot),'.pff');
        temp = GrabSignalspff(fileName,SignalExp);
        
    case '.hdf'
        fileName = strcat('pbfa2z_',num2str(shot),'.hdf');
        temp = GrabSignalshdf(fileName,sName);
end

object = temp;
object.DataLabel = 'Voltage [V]';
object.GridLabel = 'Time [s]';

end