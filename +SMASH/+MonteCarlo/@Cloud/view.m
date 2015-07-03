% view Display Cloud data
%
% under construction...
%
% view(object)
% view(object);
% view(...,'Variable',[1 3]);
% view(...,'Points','on');
% view(...,'Points','off'); % default
% view(...,'ImageMode','histogram'); % default
% view(...,'ImageMode','density');


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
function varargout=view(object,modeA,modeB)

% handle input
if (nargin<2) || isempty(modeA)
    modeA='density';
    %modeA='histogram';
end
assert(ischar(modeA),'ERROR: invalid modeA');
modeA=lower(modeA);

if (nargin<3) || isempty(modeB)
    %modeB='histogram';
    modeB='density';
end

% manage width settings
width=object.Width;
width=abs(width);
N=numel(width);
bins=cell(1,N);
for k=1:numel(width)
    value1=min(object.Data(:,k));
    value2=max(object.Data(:,k));
    if isnan(width(k))
        width(k)=(value2-value1)/(10-1);
    end
    bins{k}=value1:width(k):value2;                  
end

% create plots
figure;

ha=[];
hb=[];
for m=1:object.NumberVariables
    % single variable plot
    index=sub2ind([N N],m,m);
    ha(end+1)=subplot(N,N,index); %#ok<AGROW>
    box on;
    switch modeA
        case 'histogram'
            [count,xbin]=histogram(object,m,'xbin',bins{m});
        case 'density'
            [count,xbin]=density(object,m,width(m));
    end
    line(xbin,count,'Color','k');
    temp=sprintf('%s  ',object.VariableName{m});
    xlabel(temp);
    % cross variable plots
    for n=(m+1):N
        %index=sub2ind([N N],m,n); % lower triangle
        index=sub2ind([N N],n,m); % upper triangle
        hb(end+1)=subplot(N,N,index); %#ok<AGROW>
        box on;
        switch modeB
            case 'points'
                line(object.Data(:,m),object.Data(:,n),...
                    'LineStyle','none','Marker','.','Color','r');
            case 'histogram'
                [count,xbin,ybin]=histogram(object,[m n],...
                    'xbin',bins{m},'ybin',bins{n});
                imagesc(xbin,ybin,count);
            case 'density'
                [count,xbin,ybin]=density(object,[m n],...
                    width([m n]));
                imagesc(xbin,ybin,count);
            case 'ellipse'
                [x,y]=ellipse(object,[m n]);
                line(x,y,'Color','k');
        end
       
        xlabel(object.VariableName{m});
        ylabel(object.VariableName{n});
    end
end

% handle output
if nargout>0
    varargout{1}=ha;
    varargout{2}=hb;
end

end