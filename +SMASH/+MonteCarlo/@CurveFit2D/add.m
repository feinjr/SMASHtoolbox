% add Add measurements
%
% This method adds measurements to a CurveFt2D object.  Measurements are
% distinct (x,y) values represented by a two-dimensional probability
% density field.  These fields can be derived from two-dimensional Cloud
% objects:
%    object=add(object,cloud); % add one Cloud
%    object=add(object,cloud1,cloud2,...); % add multiple Clouds
%
% Measurements can also be defined by a table of statistical properties.
%    object=add(object,table);
%    object=add(object,table,numpoints); % custom number of cloud points
% Each row of the table is internally expressed as a two-dimensional Cloud
% object for probability density calculations.  Valid table formats are show below.
%    [xmean ymean xvar yvar]; % means and variances, zero correlation
%    [xmean ymean xvar yvar xyvar]; % manual correlation 
%    [xmean ymean xvar yvar xyvar xskew yskew]; % manual skewness
%    [xmean ymean xvar yvar xyvar xskew ysew xkurt ykurt]; % manual (excess) kurtosis
% 
% Tabular values can also be read from a data file.
%    object=add(object,filename);
%    object=add(object,filename,numpoints);
% Data files are scanned to find lines with 4, 5, 7, or 9 numeric values
% separated by white space; subsequent characters on these lines are
% ignored.  Lines that do contain valid table entries are also ignored.
% Unlike direct tabular input, the number of table columns may vary between
% measurements.
%
% See also CurveFit2D, remove, summarize
%

%
% created March 8, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function object=add(object,varargin)

% manage input
assert(nargin>1,'ERROR: insufficient input');

% process input
if isempty(object.XDomain);
    object.XDomain=[+inf -inf];
end
if isempty(object.YDomain)
    object.YDomain=[+inf -inf];
end

%mode='nothrifty';
mode='thrifty';
setting=SMASH.General.structure2list(object.DensitySettings);
sub=SMASH.MonteCarlo.Density2D(setting{:});
while numel(varargin)>0
    if isa(varargin{1},'SMASH.MonteCarlo.Cloud')
        sub=calculate(sub,varargin{1},mode);
        varargin=varargin(2:end);
        object=updateDomain(object,sub);
        object.MeasurementDensity{end+1}=sub;
        object.NumberMeasurements=object.NumberMeasurements+1;      
    elseif isnumeric(varargin{1})
        table=varargin{1};
        if (numel(varargin)>1) && isnumeric(varargin{2})
            numpoints=varargin{2};
            varargin=varargin(3:end);
        else
            numpoints=[];
            varargin=varargin(2:end);
        end
        for n=1:size(table,1)
            sub=calculate(sub,table(n,:),numpoints,mode);
            object=updateDomain(object,sub);
            object.MeasurementDensity{end+1}=sub;   
            object.NumberMeasurements=object.NumberMeasurements+1;
        end
    elseif ischar(varargin{1})
        object=readFile(object,varargin{:});
        return
    else
        error('ERROR: invalid input');
    end
end

object.Optimized=false;

end

function object=updateDomain(object,sub)

current=object.XDomain;
new=sub.Original.XDomain;
current(1)=min(current(1),new(1));
current(2)=max(current(2),new(2));
object.XDomain=current;

current=object.YDomain;
new=sub.Original.YDomain;
current(1)=min(current(1),new(1));
current(2)=max(current(2),new(2));
object.YDomain=current;

end

function object=readFile(object,filename,numpoints)

if (nargin<3) || isempty(numpoints)
    numpoints=[];
end

fid=fopen(filename,'r');
CleanupObject=onCleanup(@() fclose(fid));

while ~feof(fid)
    table=zeros(1,9);
    temp=fgetl(fid);
    [temp,count]=sscanf(temp,'%g');    
    if any(count==[4 5 7 9])
        temp=transpose(temp);
        table(1:count)=temp;
        object=add(object,table,numpoints);
    end
end

end