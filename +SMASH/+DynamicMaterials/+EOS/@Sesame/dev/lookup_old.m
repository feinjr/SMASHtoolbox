% LOOKUP Look up data values at specific grid locations
%
% This method returns interpolated data values, F, at points (X,Y) for the
% table specified by (XT, YT) and data specified by points FT. 
% The scheme uses Kerley's rational method of interpoloation : LANL report
% LA-6903-MS.
%
%    >> f=lookup(object,XT,YT,FT,x,y);
%
% XT, YT, FT are specified by strings 'Density', 'Temperature', 'Pressure',
% 'Energy', or 'Entropy'. For example:
%
%   >> P0 = lookup(object,'Density','Temperature','Pressure',rho0,T0)
%
% returns the interpolated pressure for the initial density and temperature. 
%
% Estimates of the derivatives along the x and y directions are addional
% optional outputs.
%
%   >>[f,dfx,dfy] = lookup(object,XT,YT,FT,x,y);
%
% Note: the current algorithm fails for certain combinations of grids. In
% general, 'Density' and 'Pressure' have the same format, while
% 'Temperature','Entropy', and 'Energy' have a transposed grid. A
% ('Density','Pressure') lookup, for example, will fail. In addition, there
% is no guarantee a reverse lookup (something other than 'Density',
% 'Temperature') will be valid. The iso* methods are the suggested ways to 
% generate curves.
%
% See also Sesame, hugoniot, isentrope, isobar, isotherm, isochor
%
% created April 18, 2014 by Justin Brown (Sandia National Laboratories)

function varargout=lookup(object,xt,yt,ft,x,y)

% Error checking
assert(strcmpi(object.SourceFormat,'sesame'),'ERROR: method only applies to sesame tables. A curve was detected.');

if (nargin<4) || isempty(x)
    error('ERROR: no grid location(s) specified');
end

if ~ischar(xt) || ~ischar(yt) || ~ischar(ft)
    error('Must enter strings specifying grid and data arrays. Valid options include: Density, Temperature, Pressure, Energy, and Entropy');
end

if ~isnumeric(x) || ~isnumeric(y) || numel(x) ~= numel(y) || min(size(x)) > 1
    error('Invalid format for x and y. Must enter numeric row or column vectors of equal length');
end

switch lower(xt)
    case 'density'
        xt = object.Density;
    case 'temperature'
        xt = object.Temperature;
    case 'pressure'
        xt = object.Pressure;
    case 'energy'
        xt = object.Energy;
    case 'entropy'
        xt = object.Entropy;
    otherwise
        error('Invalid option. Valid options include: Density, Temperature, Pressure, Energy, and Entropy');
end

switch lower(yt)
    case 'density'
        yt = object.Density;
    case 'temperature'
        yt = object.Temperature;
    case 'pressure'
        yt = object.Pressure;
    case 'energy'
        yt = object.Energy;
    case 'entropy'
        yt = object.Entropy;
    otherwise
        error('Invalid option. Valid options include: Density, Temperature, Pressure, Energy, and Entropy');
end

switch lower(ft)
    case 'density'
        ft = object.Density;
    case 'temperature'
        ft = object.Temperature;
    case 'pressure'
        ft = object.Pressure;
    case 'energy'
        ft = object.Energy;
    case 'entropy'
        ft = object.Entropy;
    otherwise
        error('Invalid option. Valid options include: Density, Temperature, Pressure, Energy, and Entropy');
end

f=nan(size(x));
dfx=nan(size(x));
dfy=nan(size(x));
for v = 1:length(x);   
    xv = x(v); yv = y(v);
    
    %Apply Kerley's simple two variable scheme
    %Put arrays into grid format f(x,y)
    nD = length(unique(object.Density));
    nT = length(unique(object.Temperature));
    
    xg = nan(nT,nD);
    yg = nan(nT,nD);
    fg = nan(nT,nD);
    
    
    loc = 1;
    for j = 1:nT
        xg(j,1:nD)=xt(loc:loc+nD-1);
        yg(j,1:nD)=yt(loc:loc+nD-1);
        fg(j,1:nD)=ft(loc:loc+nD-1);
        loc = loc+nD;
    end

    %Determine rotation consistent with index convention
    if xg(1,1)==xg(1,2)
        xg = transpose(xg);
        yg = transpose(yg);
        fg = transpose(fg);
    end
        
    %Find lineouts (i and j)
    xline = xg(1,:);
    n = length(xline);
    i1 = find(xv < xline,1,'first'); if isempty(i1); i1 = n; end
    i2 = find(xv > xline,1,'last'); if isempty(i2); i2 = 1; end
    i = min(i1,i2);
    if i > n-1
        i = n-1;
    end
    
    yline= yg(:,1);
    n = length(yline);
    j1 = find(yv < yline,1,'first'); if isempty(j1); j1 = n; end
    j2 = find(yv > yline,1,'last'); if isempty(j2); j2 = 1; end
    j = min(j1,j2);
    if j > n-1
        j = n-1;
    end

    
    %Interplate along each lineout
    [ri,dri] = RationalInterp(yg(:,i),fg(:,i),yv);
    [rj,drj] = RationalInterp(xg(j,:),fg(j,:),xv);
    
    [ri2,dri2] = RationalInterp(yg(:,i+1),fg(:,i+1),yv);
    [rj2,drj2] = RationalInterp(xg(j+1,:),fg(j+1,:),xv);
     

    qx = (xv-xg(j,i))./(xg(j,i+1)-xg(j,i));
    qy = (yv-yg(j,i))./(yg(j+1,i)-yg(j,i));

    r = rj.*(1-qy)+rj2.*qy+ri.*(1-qx)+ri2.*qx - ...
        fg(j,i).*(1-qx).*(1-qy) - fg(j+1,i).*(1-qx).*qy - ...
        fg(j,i+1).*(1-qy).*qx - fg(j+1,i+1).*qx.*qy;
    
    f(v) =r;
    dfx(v) = (drj+drj2)./2;
    dfy(v) = (dri+dri2)./2;
end

varargout{1} = f;
varargout{2} = dfx;
varargout{3} = dfy;
        
end




%1D Rational interpolation function scheme from G.I. Kerley's LANL report:
%LA-6903-MS. The function interpolates the tabular points ft(xt) at the
%points x and returns [f(x), df(x)].
%   >> [f,df] = RationalInterp(xt,ft,x);


function varargout=RationalInterp(xt,ft,x)
n = length(xt);
f = zeros(size(x));
df = zeros(size(x));

%Interpolate each value of x
for v = 1:length(x)
    xv = x(v);
    %assert(xv <= max(xt) && xv >= min(xt),asstr);
    if (xv >= max(xt)) && (xv <= min(xt))
        warning('%f >= %f >= %f: Value not within range of the table',max(xt),xv,min(xt));
    end

    %Find index
    i1 = find(xv < xt,1,'first'); if isempty(i1); i1 = length(xt); end
    i2 = find(xv > xt,1,'last'); if isempty(i2); i2 = 1; end
    i = min(i1,i2);
    if i > n-1
        i = n-1;
    end
    %Compute interpolation function
    q = xv-xt(i);
    d = xt(i+1)-xt(i);
    r = d-q;
    s = (ft(i+1)-ft(i))/d;

    if i == 1
        sp = (ft(i+2)-ft(i+1))/(xt(i+2)-xt(i+1));
        c2 = (sp-s)/(xt(i+2)-xt(i));
        if s*(s-d*c2) <= 0
            c2 = s/d;
        end
        frf1 = ft(i)+q*(s-r*c2);
        df1 = s+(q-r)*c2;
    elseif i == n-1
        dm = xt(i)-xt(i-1);
        sm = (ft(i)-ft(i-1))/dm;
        c1 = (s-sm)/(d+dm);
        frf1 = ft(i)+q*(s-r*c1);
        df1 = s+(q-r)*c1;
    else
        dm = xt(i)-xt(i-1);
        sm = (ft(i)-ft(i-1))/dm;
        c1 = (s-sm)/(d+dm);
        if (i ==2) && (sm*(sm-dm*c1) <= 0);c1 = (s-2*sm)/d;end
        sp = (ft(i+2)-ft(i+1))/(xt(i+2)-xt(i+1));
        c2 = (sp-s)/(xt(i+2)-xt(i));
        c3 = abs(c2*r);
        c4 = c3+abs(c1*q);
        if c4 > 0; c3 = c3/c4; end;
        c4 = c2+c3*(c1-c2);
        frf1 = ft(i)+q*(s-r*c4);
        df1 = s+(q-r)*c4+d*(c4-c2)*(1-c3);       
    end
    
    f(v) = frf1;
    df(v) = df1;
end
varargout{1} = f;
varargout{2} = df;
end