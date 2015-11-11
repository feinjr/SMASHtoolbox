% kernel density estimate
% density(object,variable,width);

function varargout=density(object,variable,width)

% handle input
if (nargin<2) || isempty(variable)
    variable=selectVariables(object,2,'bound');
end
assert(numel(variable)<=2,'ERROR: too many variables');
for k=1:numel(variable)
    assert(SMASH.General.testNumber(variable(k),'positive','integer') & ...
        variable(k)>0 & variable(k)<=object.NumberVariables,...
        'ERROR: invalid variable number');
end

if (nargin<3) || isempty(width)
    width=nan();    
end
if isscalar(width)
    width=repmat(width,[1 2]);
end

% generate density functions
switch numel(variable)
    case 1;
        x=object.Data(:,variable(1));
        if isnan(width(1))
            width(1)=std(x);
        end
        %xgrid=linspace(min(x)-3*width(1),max(x)+3*width(1),1000);
        xmin=min(x)-3*width(1);
        xmax=max(x)+3*width(1);
        dx=width(1)/5;
        xgrid=xmin:dx:xmax;
        count=zeros(size(xgrid));
        for k=1:numel(x)
            count=count+exp(-(xgrid-x(k)).^2/(2*width(1)^2))/(sqrt(2*pi)*width(1));
        end
        count=count/numel(x);
    case 2
        x=object.Data(:,variable(1));
        if isnan(width(1))
            width(1)=std(x)/2;
        end        
        xgrid=linspace(min(x)-3*width(1),max(x)+3*width(1),100);
        y=object.Data(:,variable(2));
        if isnan(width(2))
            width(2)=std(y)/2;
        end        
        ygrid=linspace(min(y)-3*width(1),max(y)+3*width(1),100);
        [xgrid,ygrid]=meshgrid(xgrid,ygrid);
        count=zeros(size(xgrid));
        %hw=waitbar(0);
        for k=1:numel(x)
            count=count+...
                exp(-(xgrid-x(k)).^2/(2*width(1)^2)-(ygrid-y(k)).^2/(2*width(2)^2))/...
                sqrt(2*pi*width(1))/width(1)/width(2);
            %waitbar(k/numel(x),hw);
            %fprintf('%4d\n',k);
        end
        count=count/numel(x);
        %delete(hw);
end

% handle output
if nargout==0
    switch numel(variable)
        case 1
            plot(xgrid,count);
        case 2
           imagesc(xgrid(1,:),ygrid(:,1),count);      
           set(gca,'YDir','normal');
    end
    figure(gcf);
else
    switch numel(variable)
        case 1
            varargout{1}=count;
            varargout{2}=xgrid;
        case 2
            varargout{1}=count;
            varargout{2}=xgrid(1,:);
            varargout{3}=ygrid(:,1);
    end
end

end