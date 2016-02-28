% reset Reset points array
%
% This method resets the points array in an existing LineSegments object.  
%     >> object=reset(object,array);
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
assert(nargin==2,'ERROR: invalid number of inputs');

assert(isnumeric(data) && ismatrix(data) && size(data,2)==2,...
    'ERROR: invalid points table');
while true
    if any(isnan(data(1,:)))
        data=data(2:end,:);
        continue
    elseif any(isnan(data(end,:)))
        data=data(1:end-1,:);
        continue
    else
        break
    end
end
object.NumberPoints=size(data,1);
object.Points=data;
% very that first two and last two enties aren't NaN?


%%
MaxSegments=object.NumberPoints+1;
object=struct();
object.Origin=nan(1,MaxSegments);
object.Direction=nan(1,MaxSegments);
object.Length=nan(1,MaxSegments);
index=0;
for k=1:object.NumberPoints
    
end


% THIS NEEDS TO BE REDONE!
% segment processing
object.Segments=nan(object.NumberPoints+1,2,3);
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