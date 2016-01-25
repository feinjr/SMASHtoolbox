function object = GrabSiDsignals(shot,LOS,format)

switch LOS
    case '170'
        sName = 'SID17';
    case '50'
        sName = 'SID05';
    case '210'
        sName = 'SID21';
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