% view Display Cloud data
%
% This method displays data cloud points for visualization.  
%    >> view(object,variable);
% Up to three cloud variables (if present) can be specified at a time.
%    >> view(object,1); % variable 1 on x-axis
%    >> view(object,[1 2]); % variable 1 on x-axis, variable 2 on y-axis
%    >> view(object,[1 2 3]); % variable 1 on x-axis, variable 2 on y-axis, variable 3 on z-axis
% Variable specification can be omitted for Clouds with 1-3 variables; for
% higher dimensions, users are prompted to select variables.
%
% See also Cloud, ellipse, hist
%

%
% created August 5, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object,variable)

% handle input
if (nargin<2) || isempty(variable)
    variable=selectVariables(object,3,'bound');
end
assert(numel(variable)<=3,'ERROR: too many plot variables');
for k=1:numel(variable)
    assert(SMASH.General.testNumber(variable(k),'positive','integer') & ...
        variable(k)>0 & variable(k)<=object.NumberVariables,...
        'ERROR: invalid variable number');
end

switch numel(variable)
    case 1
        x=object.Data(:,variable(1));
        y=ones(size(x));
        h=plot(x,y);
        xlabel(object.DataLabel{variable(1)});
        ylabel('');
        set(gca,'YTick',[]);
    case 2
        x=object.Data(:,variable(1));
        y=object.Data(:,variable(2));
        h=plot(x,y);
        xlabel(object.DataLabel{variable(1)});
        ylabel(object.DataLabel{variable(2)});
    case 3
        x=object.Data(:,variable(1));
        y=object.Data(:,variable(2));
        z=object.Data(:,variable(3));
        h=plot3(x,y,z);
        xlabel(object.DataLabel{variable(1)});
        ylabel(object.DataLabel{variable(2)});
        zlabel(object.DataLabel{variable(3)});
end
set(h,'Color',object.LineColor,'LineStyle',object.LineStyle,...
    'Marker',object.Marker,'MarkerSize',object.MarkerSize);

% handle output
if nargout>=1
    varargout{1}=h;
end

if nargout>=2
    varargout{2}=variable;
end

end