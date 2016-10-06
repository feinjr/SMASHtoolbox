% CROP - Crop the Grid of a VISAR object
%
% This method crops VISAR objects, disposing of all the information outside
% of the specified Grid bound.  The possible syntaxes are below.
%    >> object=crop(object,bound);
%    >> object=crop(object);
%
% There are two bounding options:
%     'manual' - The time window is defined by the user by selecting
%                the grid bounds on a graph of the raw signal. The 
%                selection of these bounds can be in any order. This is the
%                default
%     [t1 t2]  - The user can enter a 2 element array defining the grid
%                bounds.  The bounds can be in any order.
%
% If an experimental and/or reference ROI are already specified, this
% method will automatically adjust them to remain within the new grid
% bounds. If the ROI is completed excluded from the cropped signal, it is 
% defaulted to the whole signal for the experimental ROI and to the first 
% two grid points for the reference ROI.  
%
% created  March 15 2016 by Paul Specht (Sandia National Laboratories) 
%
function varargout=crop(object,bound)

%handle input
if nargin==1
    bound='manual';
end

if strcmpi(bound,'manual')
    view(object);
    title(gca,'Use Mouse to Select the Limiting Bounds');
    [x,~]=ginput(2);
    x=sort(x);
    close(gcf);
elseif isnumeric(bound) && (numel(bound) == 2)
    x=sort(bound);
    tmin=min(object.Measurement.Grid);
    tmax=max(object.Measurement.Grid);
    if x(1) < tmin
        x(1)=tmin;
    elseif x(1) > tmax
        error('ERROR: Invalid Boundary');
    end
    if x(2) > tmax
        x(2)=tmax;
    elseif x(2) < tmin
       error('ERROR: Invalid Boundary Limit');
    end
else
    error('ERROR: Invalid Boundary Limit');
end
object.Measurement=crop(object.Measurement,x);

%adjust the experimental Region
ER=object.ExperimentalRegion;
if ER(1) < x(1) || ER(1) > x(2)
    ER(1)=x(1);
end
if ER(2) > x(2) || ER(2) < x(1)
    ER(2)=x(2);
end
object.ExperimentalRegion=ER;

%adjust the reference region
RR=object.ReferenceRegion;
if isempty(RR) ~= 1
    if RR(1) > x(2) || RR(2) < x(1)
        RR=[object.Measurement.Grid(1) object.Measurement.Grid(2)];
    elseif  RR(1) < x(1)
        RR(1)=x(1);
    elseif RR(2) > x(2)
        RR(2)=x(2);
    end
    object.ReferenceRegion=RR;
end  

% handle output
varargout{1}=object;

end