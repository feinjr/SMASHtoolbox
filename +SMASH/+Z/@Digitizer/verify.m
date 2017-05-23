% UNDER CONSTRUCTION

function result=verify(object)

% object array
if numel(object) > 1
   
end

% scalar object

try
object=visa('AGILENT',sprintf('TCPIP::%s',list{k})); %#ok<TNMLP>
        object.Timeout=1;
        object.TimerPeriod=0.1;
        fopen(object);
        fwrite(object,'*IDN?');
        result=fscanf(object);
        if strfind(result,'KEYSIGHT')
            % OK
        elseif strfind(result,'AGILENT')
            % OK
        else
            error('');
        end
        keep(k)=true;
    catch
        continue
    end    

end