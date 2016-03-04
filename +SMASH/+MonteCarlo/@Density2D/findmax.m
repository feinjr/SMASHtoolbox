% findmax Find maximum probability density
%
% This method finds the maximum probability density on a series of line
% segments in original/scaled coordinates.
%   value=findmax(object,'original',[x y]);
%   value=findmax(object,'scaled',[u v]);
% Maximum density is determined along the line segments defined by the
% two-column table passed to this method.  NaN values in this table
% indicate line breaks where density is *not* tested.
%
% See also Density2D, lookup

%
% created March 3, 2016 by Daniel Dolan  (Sandia National Laboratories)
%
function [value,location]=findmax(object,mode,table,isnormal)

% manage input
assert(nargin>=3,'ERROR: insufficient input');

assert(ischar(mode),'ERROR: invalid mode');
mode=lower(mode);
switch mode
    case {'original' 'scaled'}
        % valid modes
    otherwise
        error('ERROR: invalid mode');
end

assert(isnumeric(table) && ismatrix(table),...
    'ERROR: invalid coordinate table');
[~,cols]=size(table);
assert(cols==2,'ERROR: invalid coordinate table');

if (nargin<4) || isempty(isnormal) || strcmpi(isnormal,'general')
    isnormal=false;
elseif strcmpi(isnormal,'normal')
    isnormal=true;
end
assert(islogical(isnormal),'ERROR: invalid normal flag');

% transform coordinates as necessary
switch mode
    case 'original'
        table=bsxfun(@minus,table,object.Original.Mean);
        table=table*object.Matrix.Forward;
end

% prepare for calculations
ubound=object.Scaled.ubound;
vbound=object.Scaled.vbound;

if isnormal
    uc=object.Scaled.Mean(1);
    vc=object.Scaled.Mean(2);
    ustd=object.Scaled.Std(1);
    vstd=object.Scaled.Std(2);
    uvar=object.Scaled.Var(1);
    vvar=object.Scaled.Var(2);
else
    increment=nan(1,2);
    increment(1)=object.Scaled.uinc/(2*object.Scaled.urange);
    increment(2)=object.Scaled.vinc/(2*object.Scaled.vrange);
    increment=min(increment);
    N=ceil(1/increment)+1;
    eta_segment=linspace(0,1,N);
    eta_segment=eta_segment(:);
end

% determine maximum density
value=0;
location=nan(1,2);
Nsegment=size(table,1)-1;
for n=1:Nsegment
    % skip breaks
    if any(isnan(table(n:n+1,:)))
        continue
    end
    % construct line segment
    u0=table(n,1);
    v0=table(n,2);
    Lu=table(n+1,1)-table(n,1);
    Lv=table(n+1,2)-table(n,2);        
    % maximum analysis
    if isnormal
        eta=(u0-uc)*Lu/uvar+(v0-vc)*Lv/vvar;
        eta=-eta/(Lu^2/uvar+Lv^2/vvar);
        if (eta>0) && (eta<1)
            eta=[0; eta(1); 1];
        else
            eta=[0; 1];
        end
        u=u0+eta*Lu;
        v=v0+eta*Lv;
        temp=1/(2*pi*ustd*vstd)*...
            exp(-(u-uc).^2/(2*uvar)-(v-vc).^2/(2*vvar)); % here
        [current,index]=max(temp);
        ucurrent=u(index);
        vcurrent=v(index);       
    else
        u=u0+eta_segment*Lu;
        v=v0+eta_segment*Lv;
        temp=object.Scaled.Lookup(u,v);
        [current,index]=max(temp);
        if isnan(current)
            current=object.Scaled.MinDensity;
        end
        ucurrent=u(index);
        vcurrent=v(index);       
    end
    if current > value
        value=current;
        location=[ucurrent vcurrent];
    end
end

% scale results as needed
switch mode
    case 'original'
        value=value*object.Matrix.Jacobian;
        location=location*object.Matrix.Reverse;
        location=location+object.Original.Mean;
end

end