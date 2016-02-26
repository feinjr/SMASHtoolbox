% add Add measurement cloud(s)
%
% This method adds measurement clouds to a two-dimensional cloud fit.
% Existing clouds can be added directly *if* they are two-dimensional.
%    object=add(object,cloud1,cloud2,...);
% Higher dimensional 
%
% Tabular definitions for new cloud properties can also be used.  At
% minimum, a five-column table must be specified to define means,
% variances, and correlations of each new cloud.
%    object=add(object,table); % table: [xm ym xvar yvar correlation]
% Each row of the input "table" defines a new Cloud object.  Cloud
% generation options are specified by name/value pairs.
%    object=add(...,'Points',numpoints); % scalar or or one-column array
%    object=add(...,'Skewness',[sx sy]); % two-column array
%    object=add(...,'Kurtosis',[kx ky]); % two-column array
% Single-row option values are applied to every new data cloud, i.e.
% options common to each cloud can be specified once.
%
% Clouds can also be read from a text file.
%    object=add(object,filename);
% Each line of the file may specify a new data cloud.  Valid cloud
% definitions have numbers separated by white space as shown below
%    xm ym xvar yvar xycorr % 5 numbers per line
%    xm ym xvar yvar xycorr points % 6 numbers per line
%    xm ym xvar yvar xycorr points xskew yskew % 8 numbers per line
%    xm ym xvar yvar xycorr points xskew yskew xkurt ykurt % 10 numbers per line
% Lines with nonumeric values or the wrong number of number values are
% ignored.
%
% See also CloudFit2D, removeMeasurement, Cloud
%

%
% created February 24, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function object=add(object,varargin)

assert(nargin>1,'ERROR: insufficient input');

% process first input
if isa(varargin{1},'SMASH.MonteCarlo.Cloud')
    object=processCloud(object,varargin{1});  
    varargin=varargin(2:end);
elseif isnumeric(varargin{1}); 
    object=processTable(object,varargin{:});
    varargin={};
elseif ischar(varargin{1}) % read from file
    object=processFile(object,varargin{1});
    varargin=varargin(2:end);
else
    error('ERROR: invalid input');
end

% continue processing input
if numel(varargin)>1
    object=add(object,varargin{:});
end

object.Processed=false;

end

%%
function object=processCloud(object,new)

assert(new.NumberVariables==2,'ERROR: only 2D clouds are permited');
object.Measurement{end+1}=new;
object.NumberMeasurements=object.NumberMeasurements+1;
object.Processed(end+1)=false;

end

%%
% xc yc xvar yvar xycorr points xskew yskew xkurtosis ykurtosis
function object=processTable(object,table,varargin)

assert(size(table,2)==5,'ERROR: invalid data table');
N=size(table,1);

% manage options
Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
option.Points=1000;
option.Skewness=[0 0];
option.Kurtosis=[0 0];
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid option name');
    value=varargin{n+1};
    assert(isnumeric(value),'ERROR: invalid value');
    switch lower(name)
        case 'points'
            option.Points=value;            
        case 'skewness'
            assert(size(value,2)==2,'ERROR: invalid skewness value');
            option.Skewness=value;
        case 'kurtosis'
            assert(size(value,2)==2,'ERROR: invalid kurtosis value');
            option.Kurtosis=value;
        otherwise 
            error('ERROR: invalid option name');
    end    
end

if isscalar(option.Points)
    option.Points=repmat(option.Points,[N 1]);
else
    option.Points=option.Points(:);
end
assert(size(option.Points,1)==N,'ERROR: inconsistent Points value');

if size(option.Skewness,1)==1
    option.Skewness=repmat(option.Skewness,[N 1]);
end
assert(size(option.Skewness,1)==N,'ERROR: inconsistent Skewness value');

if size(option.Kurtosis,1)==1
    option.Kurtosis=repmat(option.Kurtosis,[N 1]);
end
assert(size(option.Kurtosis,1)==N,'ERROR: inconsistent Kurtosis value');

% generate and add clouds
moments=nan(2,4);
correlations=eye(2);
for n=1:N
    moments(1,1)=table(n,1);
    moments(1,2)=table(n,3);
    moments(1,3)=option.Skewness(n,1);
    moments(1,4)=option.Kurtosis(n,1);
    moments(2,1)=table(n,2);
    moments(2,2)=table(n,4);
    moments(2,3)=option.Skewness(n,2);
    moments(2,4)=option.Kurtosis(n,2);
    correlations(1,2)=table(n,5);
    correlations(2,1)=correlations(1,2);
    new=SMASH.MonteCarlo.Cloud(moments,correlations,option.Points(n));
    object=add(object,new);
end  

end

%%
function object=processFile(object,file)

fid=fopen(file,'r');
C=onCleanup(@() fclose(fid));

while ~feof(fid)
    temp=fread(fid);
    [data,count,~,next]=sscanf(fid,'%g');
    temp=temp(next:end);
    if ~isempty(temp) || ~any(count==[5 6 8 10])
        continue % skip invalid lines
    end
    table=data(1:5);
    if count>=6
        points=data(6);
    else
        points=1000;
    end
    if count>=8
        skewness=data(7:8);
    else
        skewness=[0 0];
    end
    if count==10
        kurtosis=data(9:10);
    else
        kurtosis=[0 0];
    end
    object=add(object,table,...
        'Points',points,'Skewness',skewness,'Kurtosis',kurtosis);    
end

end