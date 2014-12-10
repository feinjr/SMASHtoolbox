function object=initialize(object)

object.Name='STFT object';
set(object.GraphicOptions,'Title','STFT object');

object.GridLabel='Time';
object.DataLabel='Signal';

object.FFToptions=add(object.FFToptions,'Window','gaussian',...
    @checkWindow);
    function result=checkWindow(value)
        result=false;
        if ischar(value)
            switch lower(value)
                case {'boxcar','hann','hamming','gaussian'}
                    result=true;
            end
        elseif iscell(value)
            if strcmpi(value{1},'gaussian') && isnumeric(value{2})
                result=true;
            end
        elseif isnumeric(value)
            result=true;
        end
    end
description{1}='Window: name, {name param} cell, or numeric array)';
description{end+1}='  Valid names: ''boxcar'', ''hann'', ''hamming'', or ''gaussian''';
description{end+1}='  Gaussian window customized with a cell array {''gaussian'' deviations }';
object.FFToptions=describe(object.FFToptions,'Window',...
    description,'locked');

object.FFToptions=add(object.FFToptions,'NumberFrequencies',[1000 5000],...
    @checkFrequencies);
    function result=checkFrequencies(value)
        result=false;
        if isnumeric(value)
            if numel(value)==1
                value(2)=inf;
            end                        
            if SMASH.General.testNumber(value(1),'integer')...
                    && (value(1)>0)
                % do nothing
            else
                return
            end                                                                   
            if isinf(value(2)) 
                % do nothing
            elseif SMASH.General.testNumber(value(2),'integer')...
                    && (value(2)>0) && value(2)>value(1)
                % do nothing
            else
                return
            end
            result=true;
        end
    end
object.FFToptions=describe(object.FFToptions,'NumberFrequencies',...
    'NumberFrequencies: min or [min max]','locked');

object.FFToptions=add(object.FFToptions,'RemoveDC',true,{true false});
object.FFToptions=describe(object.FFToptions,'RemoveDC',...
    'RemoveDC: true or false','locked');

end