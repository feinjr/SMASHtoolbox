% snapshot Extract snapshots (fixed times)
%
% This method extracts position-dependent information from a mesh1 object at
% fixed times.
%    >> [position,data]=snapshot(object,time);
% When the object stores multi-dimensional data, specific variables can be
% extracted with a third input.
%    >> [time,data]=snapshot(object,node,variable);
%
% If no output arguments are specified, snapshots are plotted in a new
% figure.
%
% See also mesh1, position2node
%

%
% created 9/19/2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=snapshot(object,time,variable)

% handle input
assert(nargin>=2,'ERROR: insufficient number of inputs');
time=reshape(time,[numel(time) 1]);

D=size(object,3);
if (nargin<3) || isempty(variable)
    variable=1:D;
end

% extract snapshots
node=object.Node;
result=nan([numel(time) numel(node) numel(variable)]);
[NODE,TIME]=ndgrid(object.Node,object.Time);
for k=1:numel(variable)
    DATA=transpose(object.Data(:,:,variable(k)));
    temp=interp2(TIME,NODE,DATA,time,node);
    result(:,:,k)=transpose(temp);
end

if size(object.Position,1)==1
    position=object.Position;
else
    POSITION=object.Position;
    position=interp2(TIME,NODE,POSITION,time,node);
    position=transpose(position);
end

% handle output
if nargout==0
    figure;
    N=numel(time);
    label=cell(1,N);
    for n=1:N
        label{n}=sprintf('Time = %d',time(n));
    end
    D=size(object.Data,3);
    for d=1:D
        subplot(D,1,1);
        plot(position,result(:,:,d));
        legend(label,'Location','best');
    end
else
    varargout{1}=position;
    varargout{2}=result;
end

end