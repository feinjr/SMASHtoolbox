% hist2 method for Monte Carlo data objects
%
% This method generates a 2D variable histogram from a MCdata object.
%    >> hist2(object,variable);
%%    >> hist(object,variable_number,bins);
%

%
function varargout=hist2(object,variable,xbin,ybin,haxes)

% error checking
if object.NumberVariables<2
    error('ERROR: at least two variables are needed to make a 2D histogram');
end

% handle input
if (nargin<2) || isempty(variable)
    if object.NumberVariables==2
        variable=[1 2];
    else
        valid=cell(1,object.NumberVariables);
        prompt=sprintf('Select horizontal variable number (1-%d):',object.NumberVariables);
        for k=1:object.NumberVariables
            valid{k}=sprintf('%d',k);
        end        
        while true
            variableX=input(prompt,'s');
            switch variableX
                case valid
                    break
            end
        end
        prompt=sprintf('Select vertical variable number (1-%d):',object.NumberVariables);
        for k=1:object.NumberVariables
            valid{k}=sprintf('%d',k);
        end
        while true
            variableY=input(prompt,'s');
            switch variableY
                case valid
                    break
            end
        end
        variable(1)=sscanf(variableX,'%g');
        variable(2)=sscanf(variableY,'%g');
    end
end
x=object.Data(:,variable(1));
y=object.Data(:,variable(2));

if (nargin<3) || isempty(xbin)
    xbin=10;
end
if numel(xbin)==1;
    xbin=linspace(min(x),max(x),xbin);
end
Nxbin=numel(xbin);

if (nargin<4) || isempty(ybin)
    ybin=10;
end
if numel(ybin)==1;
    ybin=linspace(min(y),max(y),ybin);
end
Nybin=numel(ybin);

if (nargin<5) || isempty(haxes)
    haxes=gca;
end

% generate histogram
left=[-inf xbin(1:end-1)];
right=[xbin(2:end) +inf];
count=zeros(Nybin,Nxbin);
for n=1:Nxbin
    temp=x(:);
    index=(temp>=left(n)) & (temp<right(n));
    temp=hist(y(index),ybin);
    count(:,n)=temp(:); 
end

% handle output
if nargout==0
    axes(haxes);
    imagesc(xbin,ybin,count);
    set(gca,'YDir','normal');
    xlabel(sprintf('Variable %d',variable(1)));
    ylabel(sprintf('Variable %d',variable(2)));
end

if nargout>=1
    varargout{1}=count;
end

if nargout>=2
    varargout{2}=xbin;
end

if nargout>=3
    varargout{2}=ybin;
end

end