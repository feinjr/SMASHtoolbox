% add Add measurement(s)
%
% This method adds measurements to an existing Measurement2D object.
% Individual measurements may be specified as two-dimensional Cloud objects
% or as a table of statistical properties.  These representations are
% converted to an approximate probability density around each measurement.
%
% object=add(object,cloud);
% object=add(object,cloud1,cloud2);
% object=add(object,table);
% object=add(object,table,numpoints);
% object=add,object,filename);
%
% mix and match??


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
            numpoints=varargin{1};
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
        break
    else
        error('ERROR: invalid input');
    end
end

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