function object = GrabCurrentsignals(shot,type,format)

switch type
    case 'jkmoore'
        switch format
            case '.pff'; fileName = strcat('z',num2str(shot),'_jkmoore.pff');                
            case '.hdf'; fileName = strcat('z',num2str(shot),'_jkmoore.hdf');
        end
    case 'tcwagon'
        switch format
            case '.pff'; fileName = strcat('z',num2str(shot),'tcwagon.pff');
            case '.hdf'; fileName = strcat('z',num2str(shot),'tcwagon.hdf');
        end        
end

biave = GrabSignalspff(fileName,'BIAVE');
bsave = GrabSignalspff(fileName,'BSAVE');
bmave = GrabSignalspff(fileName,'BMAVE');
legend = {'BIAVE', 'BSAVE', 'BMAVE'};

object = gather(biave,bmave,bsave);
object.Legend = legend;
object.GridLabel = 'Time [s]';
object.DataLabel = 'Current [A]';

end