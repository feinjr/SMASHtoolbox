% histogram Create 1D/2D histograms of Cloud data
%
% This method generates one- and two-dimensional histograms for variables
% inside of a data cloud.  The choice of variable(s) is specified by the
% second input argument.
%    >> histogram(object,2); % 1D histogram of variable 2
%    >> histogram(object,[1 3]); % 2D histogram of variables 1 and 3
% The second input is required unless the cloud only has two variables, in
% which case the histogram defaults to the first and second variables.  If
% the input is omitted in any other case, the user will be prompted to
% select one or two variables before the histogram can be generatd.
%
% When this function is called without inputs, histograms are displayed
% graphically.  By default, histograms are rendered in a new figure, but an
% existing figure can be specified as well.
%    >> histogram(object,variable,target);
% Specifying outputs suppresses graphical display and returns histogram
% information.
%    >> [xbin,count]=histogram(...); % 1D histogram
%    >> [xbin,ybin,count]=histogram(...); % 2D histogram
%
% See also Cloud, configure, density
%

% created July 21, 2013 by Daniel Dolan (Sandia National Laboratories) 
% revised August 5, 2014 by Daniel Dolan
%    -modifed input handling
% revised August 8, 2014 by Daniel Dolan
%    -changed output handling to match MATLAB hist convention
%
function varargout=histogram(object,variable,target)

% handle input
if (nargin<2) || isempty(variable)
    variable=selectVariables(object,2,'bound');
end
assert(numel(variable)<=2,'ERROR: too many plot variables');
valid=1:object.NumberVariables;
for k=1:numel(variable)
    assert(any(variable(k)==valid),'ERROR: invalid variable number');
end

NewFigure=false;
if (nargin<3) || isempty(target)
    target=[];
    NewFigure=true;
else
    assert(ishandle(target) && strcmpi(get(target,'Type'),'axes'),...
        'ERROR: invalid target axes');
end

% read data from object
data=object.Data(:,variable);

Nbin=object.NumberBins;
if numel(Nbin)==1
    Nbin=repmat(Nbin,[1 numel(variable)]);
else
    Nbin=Nbin(variable);
end

% generate histograms
switch numel(variable)
    case 1
        [count,xbin]=hist(data,Nbin);
        if nargout>0
            varargout{1}=count;
            varargout{2}=xbin;
        end
    case 2        
        xbin=linspace(min(data(:,1)),max(data(:,1)),Nbin(1));
        ybin=linspace(min(data(:,2)),max(data(:,2)),Nbin(2));
        count=zeros(Nbin(2),Nbin(1));       
        center=(xbin(1:end-1)+xbin(2:end))/2;
        left=[-inf center];
        right=[center +inf];
        for n=1:numel(xbin)
            index=(data(:,1)>=left(n)) & (data(:,1)<right(n));
            temp=hist(data(index,2),ybin); 
            count(:,n)=temp(:);
        end           
        if nargout>0
            varargout{1}=xbin;
            varargout{2}=ybin;
            varargout{3}=count;
        end
end

% handle ouput
if nargout==0
    if isempty(target)
        figure;
        target=axes('Box','on');
    else
        axes(target);
    end
    switch numel(variable)
        case 1
            h=bar(xbin,count,'hist');
            set(h,'FaceColor','none');
            if NewFigure
                xlabel(target,object.VariableName{1});
                ylabel(target,'Number of counts');
            end
        case 2
            imagesc(xbin,ybin,count);            
            set(target,'YDir','normal');            
            if NewFigure
                xlabel(target,object.VariableName{variable(1)});
                ylabel(target,object.VariableName{variable(2)});
            end
    end
end

end