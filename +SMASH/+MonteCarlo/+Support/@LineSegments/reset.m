% reset Reset points array
%
% This method resets the points array in an existing LineSegments object.  
%     >> object=resent(object,array);
% Segment information is automatically updated to match the revised Points
% property.
%
% See also LineSegments, add, remove
%

%
% created October 22, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function object=reset(object,data)

% manage input
if nargin==1
    data=object.Points;
end
if isempty(data)
    data=zeros(0,2);
end
%assert(nargin==2,'ERROR: invalid number of inputs');

if isa(data,'SMASH.MonteCarlo.Support.LineSegments')
    object=data;
    return
elseif isnumeric(data) && ismatrix(data)
    [object.NumberPoints,object.NumberDimensions]=size(data);
    object.Points=data;
else
    error('ERROR: invalid input');
end

assert(object.NumberDimensions==2,...
    'ERROR: only two-dimensinal segments are currently supported');

% segment processing
object.Segments=nan(object.NumberPoints+1,object.NumberDimensions,3);
index=0;
for k=1:(object.NumberPoints-1)
    current=object.Points(k,:);
    next=object.Points(k+1,:);
    if any(isnan(current)) || any(isnan(next))
        continue
    end
    index=index+1;
    object.Segments(index,:,1)=current;
    object.Segments(index,:,2)=next;
    object.Segments(index,:,3)=next-current;
end
 
if strcmpi(object.BoundaryType,'wrapped');
    current=object.Segments(index,:,2);
    next=object.Segments(1,:,1);
    index=index+1;
    object.Segments(index,:,1)=current;
    object.Segments(index,:,2)=next;
    object.Segments(index,:,3)=next-current;           
end

object.NumberSegments=index;
object.Segments=object.Segments(1:index,:,:);

end