% track Track histories using specified bounds
%
% UNDER CONSTRUCTION...
%
% Power spectrum tracking:
%     >> result=track(object);
%     >> result=track(object,'power',[method],[threshold]);
%
%
% Complex spectrum tracking:
%     >> result=track(object,'complex');
%
% See also STFt, analyze


function result=track(object,mode,varargin)

% manage input
if (nargin<2) || isempty(mode)
    mode='power';
end
assert(ischar(mode),'ERROR: invalid mode');

% manage boundaries
boundary=object.Boundary.Children;
if isempty(boundary)
    table=nan(2,3);
    [x,~]=limit(object);
    table(1,:)=[x(1) 0 inf];
    table(2,:)=[x(end) 0 inf];
    boundary=SMASH.ROI.BoundingCurve('horizontal',table);
    boundary.Label='Default boundary';
    boundary={boundary};
end


switch lower(mode)
    case 'power'
        result=trackPower(object,boundary,varargin{:});
    case 'complex'
        result=trackComplex(object,boundary,varargin{:});
    otherwise
        error('ERROR: %s is not a valid track mode',mode);
end
