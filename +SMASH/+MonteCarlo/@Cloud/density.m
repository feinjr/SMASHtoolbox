% UNDER CONSTRUCTION
% kernel density estimate
% density(object,variable,target);

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
numpoints=size(data,1);

Ngrid=object.NumberGridPoints;
if numel(Ngrid)==1
    Ngrid=repmat(Ngrid,[1 numel(variable)]);
else
    Ngrid=Ngrid(variable);
end

Ncontour=object.NumberContours;

% SVD reduction
center=mean(data,1);
data=bsxfun(@minus,data,center);

[U,S,V]=svd(data,0);
VT=V';
sigma=std(U);
sigma=sigma(1);
width=5*sigma;

% generate density functions
xgrid=linspace(-width,+width,Ngrid(1));
switch numel(variable)
    case 1            
        sigma=KernelWidth(U);
        xgrid=xgrid(:);
        z=zeros(Ngrid,1);
        for k=1:numpoints
            if isinf(sigma(k))
                continue
            end
            z=z+exp(-(xgrid-U(k)).^2/(2*sigma(k)^2))/sigma(k);
        end
        z=z/max(z(:));
        xgrid=xgrid*S*VT+center;
        if nargout>0
            varargout{1}=xgrid;
            varargout{2}=z;
        end
    case 2
        sigma1=KernelWidth(U(:,1));
        sigma2=KernelWidth(U(:,2));
        ygrid=linspace(-width,+width,Ngrid(2));
        [xgrid,ygrid]=meshgrid(xgrid,ygrid);
        z=zeros(Ngrid(2),Ngrid(1));
        for k=1:numpoints
            if isinf(sigma1(k)) || isinf(sigma2(k))
                continue
            end
            D2=(xgrid-U(k,1)).^2/sigma1(k)^2+(ygrid-U(k,2)).^2/sigma2(k)^2;
            z=z+exp(-D2/2)/(sigma1(k)*sigma2(k));
        end
        z=z/max(z(:));
        % contour calculation
        level=linspace(0,1,Ncontour+2);
        level=level(2:end-1);
        if isscalar(level)
            level=[level level];
        end        
        Cmatrix=contourc(xgrid(1,:),ygrid(:,1),z,level);
        % map contours back to original coordinates
        Cmatrix=transpose(Cmatrix);
        start=1;
        while start<size(Cmatrix,1)
            % read header
            M=Cmatrix(start,2);
            start=start+1;
            stop=start+M-1;
            index=start:stop;
            % transform contour data
            temp=Cmatrix(index,:);
            temp=temp*S*VT;
            temp=bsxfun(@plus,temp,center);
            Cmatrix(index,:)=temp;
            start=stop+1;
        end        
        Cmatrix=transpose(Cmatrix);
        if nargout>0
            varargout{1}=Cmatrix;
            varargout{2}=level;
        end
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

function width=KernelWidth(data)

N=numel(data);

temp=sort(data);
IQR=temp(round(0.75*N))-temp(round(0.25*N));
h=2*IQR/N^(1/3); % Freedman-Diaconis rule for ideal histogram bin width
h=4*h; % stretch the kernel over several bins
width=repmat(h,size(data));

end