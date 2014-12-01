% position2node Determine nearest mesh node(s) for specified
% 
% This method determines the nodes that are closest to a specified set of
% positions in a mesh1 object.  For static meshes, the method is called as:
%    >> node=postion2node(object,position);
% Dynamic meshes require a third input to specify when the conversion from
% position to node should be made.
%    >> node=postion2node(object,position,time);
%
% See also mesh1
%


%
% created 9/19/2014 by Daniel Dolan (Sandia National Laboratories)
%
function node=position2node(object,position,time)

% handle input
assert(nargin>=2,'ERROR: insufficient number of inputs');

if (nargin<3) || isempty(time)
    time=[];
end


% map position to node value
x=object.Position;
if size(x,1)>1
    assert(~isempty(time),'ERROR: time must be specified for moving meshes');
    t=object.Time;
    assert((time>=t(1)) & (time<=t(end)),'ERROR: invalid time specified');
    index=find(object.Time<=time,1,'last');
    if index<numel(object.Time)
        t1=t(index);
        t2=t(index+1);
        w2=(t-t1)/(t2-t1);
        w1=1-w2;
        x=w1*x(index,:)+w2*x(index+1,:);
    else
        x=x(end,:);
    end    
end

N=numel(position);
node=nan(1,N);
for n=1:N
    D2=(position(n)-x).^2;
    [~,index]=min(D2);
    node(n)=index;
    if sum(D2==D2(index))>1
        fprintf('Overlapping nodes detected at x=%g\n',position(n));
    end
   
end

end