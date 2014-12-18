% PARTITION Manage partitioning
%
% This method controls how ShortTime objects are partitiond into local
% analysis regions.  Analysis regions *always* span an integer number of
% Grid points, and regions are also separated by an integer number of Grid
% points  Partition parameters "points" and "skip" can be defined
% explicitly.
%    >> object=partition(object,'Points',points); % skip=points
%    >> object=partition(object,'Points',[points skip]);
%
% Partitioning can also be defined in terms of "duration" and "advanced"
% parameters, which use the same dimensions as the object's Grid property.
%    >> object=partition(object,'Duration',duration); % advance=duration
%    >> object=partition(object,'Duration',[duration advance]);
% The parameters "duration"/"advance" are internally converted to
% "points"/"skip".  Since "points" and "skip" must be integers, the actual
% values of "duration" and "advance" may be slightly different than
% specified.  
%
% Division into a fixed number of analysis blocks is also supported.
%    >> object=partition(object,'Blocks',blocks); % overlap=0
%    >> object=partition(object,'Blocks',[blocks overlap]);
% The spacing between region centers is determined from the "blocks"
% parameter, i.e. this parameter (in conjuction with the total number of
% points) determines the "skip" parameter. By default, each region is
% distinct from its neighbors.  Fractional overlap between regions then
% defines the number of points in each region.
%    points=(overlap+1)*skip
% Once again, the "points" and "skip" parameters must be integers, so minor
% deviations between specified and actual "blocks"/"overlap" parameters may
% be observed.
%
% NOTE: 'block' paritioning depends on the limited region of
% the object when this method is invoked (it is automatically called at
% object creation).  Changes to the limited region should be followed by a
% partition update.
%     >> object=limit(object,[left right]); % limited region change
%     >> object=partition(object,'blocks',[blocks overlap]);
% Updates are not needed for 'points' or 'duration' partitioning.
%
% To display the parameters of an object, call this method without outputs
% or parameters.
%     >> division(object);
% Parameters can also be read from (but not written to) the
% Partition property.
%     >> param=object.Partition;
%
% See also ShortTime, analyze
%

%
% created April 8, 2014 by Daniel Dolan (Sandia National Laboratories)
% revised May 14, 2014 by Daniel Dolan
%   -Renamed method from "divide" to "partition"
% revised November 11, 2014 by Daniel Dolan
%   -Changed from parameter array to parameter structure
% revised December 18, 2014 by Daniel Dolan
%   -Clarified documentation, especially regarding the limit method
function varargout=partition(object,choice,value)

% handle input
if nargin==1
    assert(nargout==0,'ERROR: partition assignment requires choice/value inputs');
    fprintf('Partition parameters:\n');
    param=object.Partition;
    fprintf('\tPoints   = %#13.0d\tSkip    = %#13.0d\n',...
        param.Points,param.Skip);
    fprintf('\tDuration = %#13.6g\tAdvance = %#13.6g\n',...
        param.Duration,param.Advance);
    fprintf('\tBlocks   = %#13.0d\tOverlap = %#13.6g\n',...
        param.Blocks,param.Overlap);
    return
end
assert(nargin==3,'ERROR: invalid number of inputs');

% error checking
assert(ischar(choice),'ERROR: invalid partition choice');

assert(isnumeric(value),...
    'ERROR: division parameter(s) must be numeric');
if numel(value)==1
    value(2)=nan;
end
assert(numel(value)==2,'ERROR: invalid number of parameters');


[t,~]=limit(object);
t1=t(1);
t2=t(end);
numpoints=numel(t);
dt=abs(t2-t1)/(numpoints-1);

% calculate points/skip for each choice
choice=lower(choice);
switch choice
    case {'point','points'}
        if isnan(value(2))
            value(2)=value(1);
        end      
        value=round(value);
        assert(all(value>1),...
            'ERROR: Points/Skip values must be greater than 1');
        points=value(1);
        skip=value(2);        
    case {'duration','durations'}
        if isnan(value(2))
            value(2)=value(1);
        end 
        assert(all(value>0),...
            'ERROR: Duration/Advance values must be greater than 0');     
        points=round(value(1)/dt);
        skip=round(value(2)/dt);        
    case {'block','blocks'}
        if isnan(value(2))
            value(2)=0;
        end
        value(1)=round(value(1));
        assert(value(1)>1,'ERROR: Blocks value must be greater than 1');        
        assert(value(2)>=0,'EROR: Overlap value must be greater than or equal to 0');                       
        skip=floor(numpoints/value(1));      
        points=(value(2)+1)*skip;        
    otherwise        
        error('ERROR: invalid division choice');
end

% calculate duration/advance and blocks/overlap
duration=points*dt;
advance=skip*dt;
blocks=floor(numpoints/skip);
overlap=(points/skip)-1;

%object.Parameter=[points skip duration advance blocks overlap];
object.Partition=struct(...
    'Points',points,'Skip',skip,...
    'Duration',duration,'Advance',advance,...
    'Blocks',blocks,'Overlap',overlap);

% handle output
varargout{1}=object;

end