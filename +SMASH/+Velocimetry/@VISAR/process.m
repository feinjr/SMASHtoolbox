% PROCESS - process a VISAR object
%
% This method processes the signals of a VSIAR object for analysis.  This
% processin involves filtering the signals and applying the vertical
% offsets and scalings.  After these operations the quadrature signals,
% fringe shift, and contrast are all determined.  This methods does not
% adjsut the fringe shift to accoutn for added or subtracted fringes.  That
% is done with the adjustFringes method.  The possilble syntaxes are listed
% below.
%     >> object=process(object,filter,params)
%     >> object=process(object,filter)
%     >> object=process(object)
% 
% Filter defines the filter used.  Params defines the parameters for that 
% filter.  There are 3 filter options
%  'None'       - Defines no signal filtering.  This is the default.  Any
%                 value entered for params is ignored
%  'Mean'       - Params should be a positive integer. The default is 3.  
%                 If params is entered as an array only the absolute value   
%                 of the rounded value of the first entry is taken.
%  'Median'     - Params should be a positive integer. The default is 3.  
%                 If params is entered as an array only the absolute value   
%                 of the rounded value of the first entry is taken.
%  Convolution' - Params should be a 3 element array of positive
%                 integers.  Only the absolute value of the rounded value
%                 of the entries are taken.
% 
% created March 14, 2016 by Paul Specht (Sandia National Laboratories) 

function varargout=process(object,FilterType,params)

% manage input
if (nargin<2) || isempty(FilterType)
    FilterType='none';
    params=[];
elseif nargin == 2
    if isnumeric(FilterType)
        error('ERROR: Invalid Filter Name');
    end
    params=[];
elseif nargin == 3
    assert(isnumeric(FilterType) == 0,'ERROR: Invalid Filter Name');
end
assert(isnumeric(params),'ERROR: Invalid Filter Parameters');
params=round(abs(params));

%filter signal
N=object.Measurement.NumberSignals;
Y=cell(1,3);
X=Y;
switch lower(FilterType)
    case 'mean'
        if numel(params) > 1
            error('ERROR:  Filter Parameter must be Scalar');
        end
        if isempty(params) % default parameter
            params=3;
        end
        kernel=ones(params,1);
        kernel=kernel/sum(kernel);
        for k=1:N
            Y{k}=conv2(object.Measurement.Data(:,k), kernel(:),'same');
        end
    case 'median'
        if numel(params) > 1
            error('ERROR:  Filter Parameter must be Scalar');
        end
        if isempty(params) % default parameter
            params=3;
        end
        for k=1:N
            Y{k}=medfilt1(object.Measurement.Data(:,k), params(1));
        end
    case 'convolution'
        if isempty(params) % default parameters
            params=[1 1 1];
        elseif numel(params) < 3 || numel(params) > 3
             error('ERROR: Invalid Filter Parameters.  Must be a 3 Element Array');
        end
        kernel=params/sum(params); % normalization
        for k=1:N
            Y{k}=conv2(object.Measurement.Data(:,k),kernel(:),'same');
        end
    case {'','none'} % do nothing, no filtering needed
        for k=1:N
            Y{k}=object.Measurement.Data(:,k);
        end
    otherwise
        error('ERROR: Invalid Filter Name.');
end
for k=1:N
    Y{k}=reshape(Y{k},size(object.Measurement.Data(:,k)));
end

%apply the vertical shifts and scaling
for k=1:N
    if length(object.VerticalOffsets) >= k
        Y{k}=Y{k}+object.VerticalOffsets(k);
    end
    if length(object.VerticalScales) >= k
        Y{k}=Y{k}*object.VerticalScales(k);
    end
    %apply the time shifts
    if length(object.TimeShifts) >= k
        X{k}=object.Measurement.Grid+object.TimeShifts(k);
    else
        X{k}=object.Measurement.Grid;
    end
end
% generate common time base
tmin=zeros(1,N);
tmax=tmin;
dt=tmin;
for m=1:N
    tmin(m)=min(X{m});
    tmax(m)=max(X{m});
    dt(m)=(tmax(m)-tmin(m))/length(X{m}); % average time step
end
Nt=ceil((min(tmax)-max(tmin))/max(dt));
T=linspace(max(tmin),min(tmax),Nt);
P=zeros(length(T),N);
for n=1:N
    [~,startloc]=min(abs(X{n}-T(1)));
    [~,endloc]=min(abs(X{n}-T(end)));
    P(:,n)=interp1(X{n}(startloc:endloc),Y{n}(startloc:endloc),T','pchip');
end

%generate the quadrature signals
if isempty(object.ReferenceRegion)
    rs=1;
    re=1;
else
    [~,rs]=min(abs(T-object.ReferenceRegion(1)));
    [~,re]=min(abs(T-object.ReferenceRegion(2)));
end
[~,es]=min(abs(T-object.ExperimentalRegion(1)));
[~,ee]=min(abs(T-object.ExperimentalRegion(2)));
D=zeros(ee-es+1,2);
DO=zeros(re-rs+1,2);
if N == 4
    DO(:,1)=P(rs:re,1)-P(rs:re,2);
    DO(:,2)=P(rs:re,3)-P(rs:re,4);
    D(:,1)=P(es:ee,1)-P(es:ee,2);
    D(:,2)=P(es:ee,3)-P(es:ee,4);
elseif N == 3
    DO(:,1)=P(rs:re,1)./P(rs:re,3);
    DO(:,2)=P(rs:re,2)./P(rs:re,3);
    D(:,1)=P(es:ee,1)./P(es:ee,3);
    D(:,2)=P(es:ee,2)./P(es:ee,3);
else
    DO(:,1)=P(rs:re,1);
    DO(:,2)=P(rs:re,2);
    D(:,1)=P(es:ee,1);
    D(:,2)=P(es:ee,2);
end

%calculate fringe shift
x0=object.EllipseParameters(1);
y0=object.EllipseParameters(2);
Lx=object.EllipseParameters(3);
Ly=object.EllipseParameters(4);
epsilon=object.EllipseParameters(5);
xR=(DO(:,1)-x0)/Lx;
yR=(DO(:,2)-y0)/Ly;
phaseR=atan2(yR+xR*sin(epsilon),xR*cos(epsilon));
phaseR=mean(unwrap(phaseR));
x=(D(:,1)-x0)/Lx;
y=(D(:,2)-y0)/Ly;
phase=atan2(y+x*sin(epsilon),x*cos(epsilon));
phase=unwrap(phase,pi); % deal with phase wraps
fringeshift=(phase-phaseR)/(2*pi);

% calculate contrast
contrast0=sqrt(DO(:,1).^2+2*DO(:,1).*DO(:,2)*sin(epsilon)+DO(:,2).^2)*sec(epsilon);
contrast0=mean(contrast0);
contrast=sqrt(D(:,1).^2+2*D(:,1).*D(:,2)*sin(epsilon)+D(:,2).^2)*sec(epsilon);
if (contrast0 < min(contrast)) || (contrast0 == 0);
    warndlg(...
        'Low initial contrast--check initial time setting',...
        'Low initial contrast');
else
    contrast=contrast/contrast0;
end
          
%Save resutls
object.Processed=SMASH.SignalAnalysis.SignalGroup(T',P);
object.Quadrature=SMASH.SignalAnalysis.SignalGroup(T(es:ee)',D);
object.FringeShift=SMASH.SignalAnalysis.Signal(T(es:ee)',fringeshift);
object.Contrast=SMASH.SignalAnalysis.Signal(T(es:ee)',contrast);
varargout{1}=object;

end