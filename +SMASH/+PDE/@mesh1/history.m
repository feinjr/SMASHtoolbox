% history Extract histories (fixed node location)
%
% This method extracts time-dependent information from a mesh1 object at
% fixed node locations.
%    >> [time,data]=history(object,node);
% Node values are used instead of positions to avoid confusion in the case
% of overlapping node points.  When the object stores multi-dimensional
% data, specific variables can be extracted with a third input.
%    >> [time,data]=history(object,node,variable);
%
% If no output arguments are specified, histories are plotted in a new
% figure.
%
% See also mesh1, position2node
%

%
% created 9/19/2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=history(object,node,variable)

% handle input
assert(nargin>=2,'ERROR: insufficient number of inputs');
node=reshape(node,[1 numel(node)]);
node=round(node);
assert(all(node>=1) & all(node<=numel(object.Node)),...
    'ERROR: invalid node requested');

D=size(object,3);
if (nargin<3) || isempty(variable)
    variable=1:D;
end

% extract histories
time=object.Time;
result=nan([numel(time) numel(node) numel(variable)]);
[NODE,TIME]=ndgrid(object.Node,object.Time);
%[NODE,TIME]=meshgrid(object.Node,time);
for k=1:numel(variable)
    DATA=transpose(object.Data(:,:,variable(k)));
    temp=interp2(TIME,NODE,DATA,object.Time,node);
    result(:,:,k)=transpose(temp);
end

% handle output
if nargout==0
    figure;
    N=numel(node);
    label=cell(1,N);
    for n=1:N
        label{n}=sprintf('Node = %d',node(n));
    end
    D=size(object.Data,3);
    for d=1:D
        subplot(D,1,1);
        plot(time,result(:,:,d));
        legend(label,'Location','best');
    end            
else
    varargout{1}=time;
    varargout{2}=result;
end

end