% density Estimate probability density
% 
% This function estimates the probability density function for the data in
% a cloud.  Each data point is represented by a local Gaussian kernel that
% contributes to the overal density.  Density estimates can be generated
% for one or two cloud variables.
%    density(object,1); % density estimate for variable 1
%    density(object,[1 3]); % joint density estimate for variables 1 and 3
% When the method is called with no output, density plots are displayed in
% a new figure.  Plots may be rendered in an exising axes by passing a
% handle as the third input.
%    density(object,variable,target);
%
% Specifying outputs suppresses plot display and returns density
% information.
%    [x,Px]=density(object,variable); % 1D density
%    [Cmatrix,level]=density(object,variable); % 2D density
%
% See also Cloud, configure, histogram
%

%
% created November 18, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=density(object,variable,target)

% manage input
if (nargin<2) || isempty(variable)
    variable=selectVariables(object,2,'bound');
end
assert(numel(variable)<=2,'ERROR: too many variables');
valid=1:object.NumberVariables;
for k=1:numel(variable)
    assert(any(variable(k)==valid),'ERROR: invalid variable number');
end

NewFigure=false;
if (nargin<3) || isempty(target)
    NewFigure=true;
    target=[];
else
    assert(ishandle(target) && strcmpi(get(target,'Type'),'axes'),...
        'ERROR: invalid target axes');
end

% read data from object
data=object.Data(:,variable);
%numpoints=size(data,1);

Ngrid=object.NumberGridPoints;
%if numel(Ngrid)==1
%    Ngrid=repmat(Ngrid,[1 numel(variable)]);
%else
%    Ngrid=Ngrid(variable);
%end

Ncontour=object.NumberContours;

% generate density
switch numel(variable)
    case 1
        [weight,grid]=SMASH.MonteCarlo.density1('fft',data,Ngrid);
    case 2
        [weigth,grid1,grid2]=SMASH.MonteCarlo.density2('fft',...
            data,Ngrid,Ngrid);
end

% handle output
if nargout==0
    if isempty(target)
        figure
        target=axes('Box','on');
    else
        axes(target);
    end
    switch numel(variable)
        case 1
            line(xgrid,z);
            if NewFigure
                xlabel(object.VariableName{variable});
                ylabel('Relative density');
            end
        case 2
           SMASH.Graphics.plotContourMatrix(Cmatrix,target);
           if NewFigure
               xlabel(object.VariableName{variable(1)});
               ylabel(object.VariableName{variable(2)});
           end
    end
    figure(gcf);
end

end

