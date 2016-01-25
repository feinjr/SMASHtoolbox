function object = GrabPCDsignals(shot,LOS,format)

switch LOS
    case '170'
        sName = 'PCD17';
    case '50'
        sName = 'PCD05';
    case '210'
        sName = 'PCD21';
end
switch format
    case '.pff'
        fileName = strcat('pbfa2z_',num2str(shot),'.pff');
        temp = GrabSignalspff(fileName,sName);

    case '.hdf'
        fileName = strcat('pbfa2z_',num2str(shot),'.hdf');
        temp = GrabSignalshdf(fileName,sName);        
end

object = temp;
object.DataLabel = 'Voltage [V]';
object.GridLabel = 'Time [s]';

end