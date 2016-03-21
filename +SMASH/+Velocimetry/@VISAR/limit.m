% LIMIT - Defines a region of interest (ROI) for a VISAR object
%
% This method defines a ROI in a VISAR object for processing and analysis.
% The possible sytaxes are below.
%     >> object=limit(object,type,bound); 
%     >> object=limit(object,type); 
%     >> object=limit(object,bound); 
%     >> object=limit(object); 
%
% Type defines the ROI.  There are two options.
%      'experimental - This refers to the experimental ROI. This is the 
%                      portion of the signal that will be used for analysis
%                      This is the default.
%      'reference'   - This refers to the reference region for defining
%                      initial contrast.
%
% Bound defines the limits for the region type. There are three ways to 
% specify this:
%       'manual'    - The time window is defined by the user by selecting
%                     the bounds of the ROI on a graph of the raw signal.  
%                     The selection of these bounds can be in any order. 
%                     This is the default
%       'all'       - Sets the ROI to the entire time window of the signal
%       [t1 t2]     - The user can enter a 2 element array defining the ROI
%                     bounds.  The bounds can be in any order.
%
% The experimental and reference ROI bounds are not a protected property.
% The user can also just reset them in the command window
%      >> object.ReferenceRegion=[t1 t2];
%      >> object.ExperimentRegion=[t1 t2];
%
% When a new VISAR object is created the default experimental ROI is set to
% the entire signal.  The default reference ROI is set to the first two
% points of the singal.  
%                
% created March 15, 2015 by Paul Specht (Sandia National Laboratories)
%
function varargout=limit(object,type,bound)

if nargin==1
    type='experimental';
    bound='manual';
elseif nargin == 2
    if strcmpi(type,'experimental') || strcmpi(type,'reference')
        bound='manual';
    elseif  strcmpi(type,'manual') || strcmpi(type,'all')
        bound=type;
        type='experimental';
    elseif isnumeric(type) && (numel(type) == 2)
        bound=type;
        type='experimental';
    else
        error('ERROR: Invalid Limit Input');
    end
elseif nargin == 3
    if strcmpi(type,'experimental') || strcmpi(type,'reference')
        %nothing
    else
        error('ERROR: Invalid ROI Specification');
    end
end

if strcmpi(bound,'all')
    if strcmpi(type,'experimental')
        object.ExperimentalRegion=[object.Measurement.Grid(1) object.Measurement.Grid(end)];
    else
        object.ReferenceRegion=[object.Measurement.Grid(1) object.Measurement.Grid(end)];
    end
elseif strcmpi(bound,'manual')
    view(object);
    title(gca,'Use Mouse to Select the Limiting Bounds');
    [x,~]=ginput(2);
    x=sort(x);
    if strcmpi(type,'experimental')
        object.ExperimentalRegion=[x(1) x(2)];
    else
        object.ReferenceRegion=[x(1) x(2)];
    end
    close(gcf);
elseif isnumeric(bound) && (numel(bound) == 2)
    bound=sort(bound);
    tmin=[object.Measurement.Grid(1) bound(1)];
    tmax=[object.Measurement.Grid(end) bound(2)];
    if max(tmin) > min(tmax)
        error('ERROR: Invalid Limit Bound');
    end
    if strcmpi(type,'experimental')
        object.ExperimentalRegion=[max(tmin) min(tmax)];
    else
        object.ReferenceRegion=[max(tmin) min(tmax)];
    end
else
    error('ERROR: Invalid Limit Bound');
end

% handle output
varargout{1}=object;

end
