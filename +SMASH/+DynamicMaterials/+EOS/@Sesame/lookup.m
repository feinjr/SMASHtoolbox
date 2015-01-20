% LOOKUP Look up data values at specified density and temperature
%
% This method returns interpolated data values, ZT, at points (X,Y) for the
% table specified by (XT, YT) and data specified by points ZT. 
% The scheme uses Kerley's rational method of interpoloation : LANL report
% LA-6903-MS.
%
%    >> f=lookup(object,ZT,density,temperature);
%
% Z is specified by strings 'Pressure','Energy', or 'Entropy'. 
%
% For example:
%
%   >> P0 = lookup(object,'Pressure',rho0,T0)
%
% returns the interpolated pressure for the initial density and temperature. 
%
% Estimates of the derivatives along the x and y directions are addional
% optional outputs.
%
%   >>[f,dfx,dfy] = lookup(object,ZT,x,y);
%
% See also Sesame, reverselookup, hugoniot, isentrope, isobar, isotherm, isochor
%

% created April 18, 2014 by Justin Brown (Sandia National Laboratories)

function varargout=lookup(object,zt,x,y)

% Error checking
assert(strcmpi(object.SourceFormat,'sesame'),'ERROR: method only applies to sesame tables. A curve was detected.');

if (nargin<2) || isempty(x)
    error('ERROR: no grid location(s) specified');
end

if  ~ischar(zt)
    error('Must enter strings specifying data array. Valid options include: Pressure, Energy, and Entropy');
end

if ~isnumeric(x) || ~isnumeric(y) || numel(x) ~= numel(y) || min(size(x)) > 1
    error('Invalid format for x and y. Must enter numeric row or column vectors of equal length');
end


switch lower(zt)
    case 'pressure'
        zt = object.Pressure;
    case 'energy'
        zt = object.Energy;
    case 'entropy'
        zt = object.Entropy;
    otherwise
        error('Invalid data (Z) option. Valid options include: Pressure, Energy, and Entropy');
end

xt = unique(object.Density);
yt = unique(object.Temperature);

nx = numel(xt);
ny = numel(yt);

%Put z on grid
loc = 1;
for j = 1:ny
    zg(1:nx,j) = zt(loc:loc+nx-1);
    loc = loc+nx;
end

z=nan(size(x));
dzx=nan(size(x));
dzy=nan(size(x));

for v = 1:length(x)   
    xv = x(v); yv = y(v);
    
    %Make sure requested values are within range of table
    asstr = sprintf('%f >= %f >= %f: Value not within range of the table',max(xt),xv,min(xt));
    %assert(xv <= max(xt) && xv >= min(xt),asstr);
    if (xv >= max(xt) && xv <= min(xt)); warning(asstr); end;
    
    asstr = sprintf('%f >= %f >= %f: Value not within range of the table',max(yt),yv,min(yt));
    %assert(yv <= max(yt) && yv >= min(yt),asstr);
    if (yv >= max(yt) && yv <= min(yt)); warning(asstr); end;
           
    [z(v),dzx(v),dzy(v)] = interp_2D(xt,yt,zg,xv,yv);
    
    varargout{1} = z;
    varargout{2} = dzx;
    varargout{3} = dzy;
end
end


%Port of Kyle Cochran's IDL routine
function varargout=interp_2D(xt,yt,zt,x,y)
    
    nx = numel(xt);
    ny = numel(yt);

    ix = find(xt < x,1,'last'); if isempty(ix); ix = 1; end;
    iy = find(yt < y,1,'last'); if isempty(iy); iy = 1; end;
    
    i = ix;
    j = iy;
    
    s1 = x-xt(i);
    s2 = xt(i+1)-xt(i);
    
    for k = 1:2
        i = ix;
        j = iy+k-1;
        s5 = (zt(i+1,j)-zt(i,j))/s2;
        
        if (ix > 1)
            s3 = xt(i)-xt(i-1);
            s6 = (zt(i,j)-zt(i-1,j))/s3;
            s7 = (s5-s6)/(s2+s3);
        else
            s3 = 0.0;
            s6 = 0.0;
            s7 = 0.0;
        end
        
        if( (ix == 1) & (s6*(s6-s3*s7) <= 0.0) ) 
            s7 = (s5-2.0*s6)/s2 ;
        end

        if (nx-ix > 2) 
            s3 = xt(i+2)-xt(i+1) ;
            s6 = ((zt(i+2,j)-zt(i+1,j))/s3-s5)/(s2+s3);
        else
            s6 = 0.0;
        end
 
        if( (ix <= 0) & (s5*(s5-s2*s6) <= 0.0) ) 
            s6 = s5/s2;
        end
        
        s8 = abs(s6*(s2-s1));
        s3 = s8+abs(s7*s1);

        if(s3 > 0.0); s8 = s8/s3; end
        if(ix <= 0); s8=0.0; end
        if(nx-ix <= 2); s8 = 1.0; end
 
        s3 = s6+s8*(s7-s6);
        s4 = 0.5*(zt(i,j)+s1*s5)-s1*(s2-s1)*s3;
        s5 = 0.5*s5+(2.0*s1-s2)*s3+s2*s8*(1.0-s8)*(s7-s6); 
 
        if(k == 1)
            z1 = s4; 
            z2 = s5; 
        else
            j = iy;
            s1 = y-yt(j);
            s2 = yt(j+1)-yt(j); 
            z3 = (s4-z1)/s2; 
            z1 = z1+z3*s1; 
            z2 = z2+(s5-z2)*s1/s2; 
        end
    end

    for k=1:2
        i = ix+k-1;
        j = iy; 
        s5 = (zt(i,j+1)-zt(i,j))/s2; 

        if(iy > 1) 
            s3 = yt(j)-yt(j-1); 
            s6 = (zt(i,j)-zt(i,j-1))/s3; 
            s7 = (s5-s6)/(s2+s3); 
        else
            s7 = 0.0; 
        end

        if( (iy == 1) & (s6*(s6-s3*s7) <= 0.0) )
            s7 = (s5-2.0*s6)/s2;
        end

        if(ny-iy > 2)
            s3 = yt(j+2)-yt(j+1);
            s6 = ((zt(i,j+2)-zt(i,j+1))/s3-s5)/(s2+s3); 
        else
            s6 = 0.0;
        end

        if ((iy <= 0) & (s5*(s5-s2*s6) <= 0.0) ) 
            s6 = s5/s2;
        end

        s8 = abs(s6*(s2-s1)); 
        s3 = s8 +abs(s7*s1); 

        if(s3 > 0.0); s8 = s8/s3; end 
        if(iy <= 0); s8 = 0.0; end
        if(ny-iy <= 2); s8 = 1.0; end 

        s3 = s6+s8*(s7-s6);
        s4 = 0.5*(zt(i,j)+s1*s5)-s1*(s2-s1)*s3; 
        s5 = 0.5*s5+(2.0*s1-s2)*s3+s2*s8*(1.0-s8)*(s7-s6); 

        if(k == 1)
            z1 = z1+s4;
            z3 = z3+s5; 
            i = ix; 
            s4 = -s4/(xt(i+1)-xt(i)); 
            z1 = z1+s4*(x-xt(i)); 
            z2 = z2+s4; 
            z3 = z3-s5*(x-xt(i))/(xt(i+1)-xt(i)); 
        else
            i = ix;
            s4 = s4/(xt(i+1)-xt(i)); 
            z1 = z1+s4*(x-xt(i)); 
            z2 = z2+s4; 
            z3 = z3+s5*(x-xt(i))/(xt(i+1)-xt(i)); 
        end
    end

    varargout{1} = z1;
    varargout{2} = z2;
    varargout{3} = z3;
end

