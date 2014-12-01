function object=refresh(object)

% seed random generator
seed=object.Seed;
if ischar(seed)
    % convert string to number
end

if ~isempty(seed)
    s=RandStream('mt19937ar','Seed',seed);
    RandStream.setGlobalStream(s);
end

% generate table    
object.Data=MCinput(object.Moments,object.Correlations,...
    object.NumberPoints);
object.Source='moments';

end