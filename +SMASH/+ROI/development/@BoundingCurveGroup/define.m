% define Define objects in a group
%
% This method manually defines the BoundingCurve objects in a group.
% Baounaries can be passed as distinct arguments:
%     >> define(group,bound1,bound2,...);
% or as a cell array.
%     >> define(group,array);
% CAUTION: this method overwrite the Children property!
%
% See also BoundingCurveGroup
%


%
% created December 16, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function define(object,varargin)

% manage input
assert(nargin>1,'ERROR: insufficient input');

N=numel(varargin);
if (N==1) && iscell(varargin{1})
    array=varargin{1};
else
    array=cell(1,N);
    for n=1:N
        array{n}=varargin{n};
    end
end

% error checking
for n=1:numel(array)
    assert(isa(array{n},'SMASH.ROI.BoundingCurve'),...
        'ERROR: invalid group element detected');
end

% define Children property
object.Children=array;