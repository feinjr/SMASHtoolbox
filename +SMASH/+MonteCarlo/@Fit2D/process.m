% process Process measurement clouds
%
% *before* analyze is used!
function object=process(object,GridPoints,SmoothFactor,PadFactor)

% manage input
if (nargin<2) || isempty(GridPoints)
    GridPoints=100;
end
if isscalar(GridPoints)
    GridPoints=repmat(GridPoints,[1 2]);
end
assert((numel(GridPoints)==2) ...
    && all(GridPoints>0) && all(GridPoints==round(GridPoints)),...
    'ERROR: invalid GridPoints value');

if (nargin<3) || isempty(SmoothFactor)
    SmoothFactor=2;
end
assert(isnumeric(SmoothFactor) && isscalar(SmoothFactor) ...
    && (SmoothFactor>0),'');

if (nargin<4) || isempty(PadFactor)
    PadFactor=5;
end

%ContourLevels=5;

assert(isnumeric(PadFactor) && isscalar(PadFactor) ...
    && (PadFactor>0),'');

% process measurements
for m=1:object.NumberMeasurements
    result=struct();
    % prepare data
    data=object.Measurement{m}.Data; % [x y]
    Npoints=size(data,1);
    result.OriginalMean=mean(data,1);
    data=bsxfun(@minus,data,result.OriginalMean);
    % singular value decomposition
    [data,D,C]=svd(data,0);
    %result.FinalTable=data; % [u v]
    result.BackwardMatrix=D*transpose(C); % principle to actual coordinates
    Dinv=diag(1./diag(D));
    result.ForwardMatrix=C*Dinv; % actual to principle coordinates
    % normal distribution parameters
    result.FinalMean=mean(data,1);
    result.FinalStd=std(data,[],1);
    result.FinalVar=var(data,[],1);
    % density estimation
    width=result.FinalStd/Npoints^(1/5); % Silverman's rule
    width=width*SmoothFactor;
    normgrid=cell(1,2);
    table=nan(Npoints,2);
    ku=cell(1,2);
    N2=pow2(nextpow2(GridPoints));
    for n=1:2
        % 
        span=max(abs(data(:,n)))+PadFactor*width(n);        
        temp=linspace(-span,+span,GridPoints(n));        
        normgrid{n}=temp(:);
        %
        bin1=temp(1);
        spacing=(temp(end)-temp(1))/(GridPoints(n)-1);        
        temp=round((data(:,n)-bin1)/spacing)+1;
        temp(temp<1)=1;
        temp(temp>GridPoints(n))=GridPoints(n);   
        table(:,n)=temp;        
        %
        start=-N2(n)/2;
        stop=+N2(n)/2-1;
        temp=(start:stop)/(N2(n)*spacing);
        ku{n}=ifftshift(temp(:));
    end
    Q=accumarray(table,1,GridPoints); % simple binning  
    Q(N2(1),N2(2))=0; % zero padding
    P=fftn(Q);
    for n=1:2
        temp=exp(-2*pi^2*width(n)^2*ku{n}.^2);
        index=ones(1,2);
        index(n)=N2(n);
        temp=reshape(temp,index);
        index=N2;
        index(n)=1;
        temp=repmat(temp,index);
        P=P.*temp;
    end
    density=ifftn(P,'symmetric');
    density=density(1:GridPoints(1),1:GridPoints(2));
    threshold=max(density(:))*1e-9;
    density(density<threshold)=threshold;    
    % normalization
    mass=trapz(normgrid{1},density);
    mass=trapz(normgrid{2},mass);
    density=density/mass;
    % interpolant
    [u,v]=ndgrid(normgrid{1},normgrid{2});
    result.FinalDensityLookup=griddedInterpolant(u,v,density,'linear','none');
    % density image and boundary
    density=transpose(density);    
    temp=SMASH.ImageAnalysis.Image(...
        normgrid{1},normgrid{2},density);
    temp.GraphicOptions.AspectRatio='equal';
    result.FinalDensityImage=temp;
    threshold=max(density(:))*exp(-2^2/2);
    temp=contourc(normgrid{1},normgrid{2},density,...
        [threshold threshold]);
    temp=SMASH.Graphics.contours2lines(temp);
    temp=temp{1}*result.BackwardMatrix;
    result.OriginalBoundary=bsxfun(@plus,temp,result.OriginalMean);
    % store results
    result=orderfields(result);
    object.ProcessedResult{m}=result;
end

object.Processed=true;

end

% YOU ARE HERE
%
% We don't really need to keep the cloud points around, do we?
% Points can be converted to a Density structure
%   -FowardMatrix (original to final coordinates)
%   -ReverseMatrix (final to original coordinates)
%   -OriginalMean
%   -OriginalBoundary (one contour)
%   -Mean
%   -Std
%   -Var
%   -Table
%   -Image