% REVERSELOOKUP Look up temperature value at specified density and data
%
% This method returns the temperature for a specified data value, z and
% density.
%
%    >> t=reverselookup(object,ZT,z,density);
%
% Z is specified by strings 'Pressure','Energy', or 'Entropy'. 
%
% For example:
%
%   >> T0 = reverselookup(object,'Pressure',0,rho0)
%
% returns the interpolated temperature for 0 pressure and the initial
% density.
%
% See also Sesame, lookup, hugoniot, isentrope, isobar, isotherm, isochor
%

% created April 18, 2014 by Justin Brown (Sandia National Laboratories)

function varargout=reverselookup(object,ZT,z,x)

% Error checking
assert(strcmpi(object.SourceFormat,'sesame'),'ERROR: method only applies to sesame tables. A curve was detected.');

if (nargin<2) || isempty(x)
    error('ERROR: no grid location(s) specified');
end

if  ~ischar(ZT)
    error('Must enter strings specifying data array. Valid options include: Pressure, Energy, and Entropy');
end

if ~isnumeric(z) || ~isnumeric(x) || numel(z) ~= numel(x) || min(size(z)) > 1
    error('Invalid format for x and y. Must enter numeric row or column vectors of equal length');
end


switch lower(ZT)
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


y=nan(size(x));

for v = 1:length(x)   
    xv = x(v); zv = z(v);
    
    %Make sure requested values are within range of table
    asstr = sprintf('%f >= %f >= %f: Value not within range of the table',max(xt),xv,min(xt));
    assert(xv <= max(xt) && xv >= min(xt),asstr);
    
    try
        y(v) = reverse_2D(xt,yt,zg,zv,xv);
    catch
        warning('reverse lookup failure, using fzero')
        if v>1
            y(v) = fzero(@(x) lookup(object,ZT,xv,x)-zv,y(v-1));
        else
            y(v) = fzero(@(x) lookup(object,ZT,xv,x)-zv,300);
        end
    end
    
    varargout{1} = y;
end

end


%Port of Kyle Cochran's IDL routine
function y = reverse_2D(xt,yt,zt,z,x)

    nx = numel(xt);
    ny = numel(yt);
    
    temp_y=zeros(5);

    PERR = 1.0e-7;
    P01 = 0.01; 
    s10 = 0.0;

    %Get x location
    ix = find(xt < x,1,'last');
    if isempty(ix) | ix == 1; ix = 2; end
    is1 = ix;


    %Get approximate first guess y location
    s2 = z;
    s3 = (x-xt(ix))/(xt(ix+1)-xt(ix));
    is1 = ix;
    is2 = 0;
    is3 = ny-1;

    while(is3-is2 ~= 1)
        m = int32((0.5*(is2+is3)));
        iy = (m-1);
            
        if( s2 > (1.0-s3)*zt(is1,iy)+s3*zt(is1+1,iy) )
            is2 = m;
        else
            is3 = m;
        end
        s5 = Sesrt1(xt,zt,x,ix,iy);
    end

    ix = is1;
    iy = is2;

    s5 = Sesrt1(xt,zt,x,ix,iy);
    s2 = yt(iy);
    iy = iy+1;
    s3 = yt(iy);
    s6 = Sesrt1(xt,zt,x,ix,iy);

    %Make sure J indices bracket variable Y

    iy=iy-1;
    s1 = (s6-z)*(z-s5); 

    if( ((iy == 0) & (z < s5)) | ...
            ((iy == ny-2) & (z > s6)) ) 
        s1 = 0.0;
    end

    if(s1 < 0.0)
        if(z < s5)
            if(iy ~= 0)
                while(1)
                    iy=iy-1;
                    s6 = s5; 
                    s5 = Sesrt1(xt,zt,x,ix,iy); 
                    s2 = yt(iy);
                if( (z >= s5) | (iy == 0)) 
                    break;
                end

                end
            else
                while( (z >= s6) & (iy ~= ny-2) )
                    iy=iy+2 
                    s5 = s6 
                    s6 = Sesrt1(xt,zt,x,ix,iy) 
                    iy=iy-1
                    s3 = yt(iy+1) 
                end
            end
        end
    end

   %Make 2 sweeps over Y variable

    i = ix;
    s7 = (x-xt(i))/(xt(i+1)-xt(i)); 
    j = iy; 
    s8 = yt(j+1)-yt(j);
    s6 = (s6-s5)/s8; 
    y = 0.5*s8; 
    if(j > 0)
        s2 = yt(j-1);
    end
    if(ny-j > 2) 
        s3 = yt(j+2);
    end

    temp_y(1) = s1; 
    temp_y(2) = s2; 
    temp_y(3) = s3; 
    temp_y(4) = 0.0; % s4

    for k=1:2
        i = ix+k-1; 
        j = iy; 
        s12 = (zt(i,j+1) - zt(i,j))/s8; 

        if(j > 0)
            s10 = yt(j)-yt(j-1); 
            temp_y(k) = (zt(i,j)-zt(i,j-1))/s10;
            temp_y(k+2) = (s12-temp_y(k))/(s8+s10); 
        end
            temp_y(k) = 0.0; 

        if( (j == 1) & (temp_y(k)*(temp_y(k)-s10*temp_y(k+2)) <= 0.0) )
            temp_y(k+2) = (s12-2.0*temp_y(k))/s8;
        end

        if(ny-j > 2)
            s10 = yt(j+2)-yt(j+1);
            temp_y(k) = ((zt(i,j+2) - zt(i,j+1))/s10-s12)/(s8+s10); 
        end
          temp_y(k) = 0.0;

        if( (j <= 0) & (s12*(s12-s8*temp_y(k)) <= 0.0) ) 
            temp_y(k) = s12/s8
        end
    end
    s1 = temp_y(1); 
    s2 = temp_y(2); 
    s3 = temp_y(3); 
    s4 = temp_y(4); 

    %Begin iteration on variable Y (maximum number of iterations is 50)

    s14 = 1.0;

    for l=1:5
        smx = -1.0; 
        if(s14 > 0.0)
            j = iy;
            s12 = abs(s1*(s8-y)); 
            s11 = s12 + abs(s3*y); 

            if(s11 > 0.0)
                s12 = s12/s11;
            end

            if(j <= 0)
                s12 = 0.0;
            end
            if(ny-j <= 2)
                s12 = 1.0;
            end

            s11 = s1+s12*(s3-s1); 
            s12 = (1.0-s12)*(s11-s1);
            s9 = abs(s2*(s8-y)); 
            s10 = s9+abs(s4*y); 

            if(s10 > 0.0)
                s9 = s9/s10;
            end
            if(j <= 0)
                s9 = 0.0;
            end

            if(ny-j <= 2)
                s9 = 1.0;
            end

            s10 = s2+s9*(s4-s2); 

            if( (z >= s5) & (z <= s5+s6*s8) )
                s11 = s11 + (s10-s11)*s7; 
                s12 = s12 + ((1.0-s9)*(s10-s2)-s12)*s7; 
            else
                s11 = 0.0; 
                s12 = 0.0;
            end

            dzy = s6+(2.0*y-s8)*s11+s8*s12;
            s11 = -y*(s8-y)*s11+s5+s6*y; 

            if(dzy > 0.0)
                s9 = (z-s11)/dzy;
            else
                s9 = P01*abs(s8)*sign(z-s11);
            end
            
            y = y+s9;
            s13 = abs(s9) - PERR*abs(s8);
            s14 = abs(z-s11)-PERR*(abs(z)+PERR); 
            s14 = (s13<s14);
        end
        smx = (smx>s14);
        if(smx <= 0.0)
            l=51;
        end
    end

%End iteration on variable Y

    j = iy;
    y = y+yt(j); 

    if(s14 <= 0.0)
        s1 = 1.0;
    else
        s1 = -1.0;
    end
    
end



function z = Sesrt1(xt,zt,x,ix,iy)

    nx = numel(xt);

    i = ix; 
    j = iy; 

    s2 = xt(i+1)-xt(i); 
    s6 = (zt(i+1,j) - zt(i,j))/s2;

    if(ix > 0)
        z = xt(i) - xt(i-1); 
        s4 = (zt(i,j)-zt(i-1,j))/z; 
        s5 = (s6-s4)/(s2+z); 
    else
        s5 = 0.0;
        s4 = 0.0;
        z= 0.0;
    end

    if( (ix == 1) & (s4*(s4-z*s5) <= 0.0) ) 
        s5 = (s6-2.0*s4)/s2;
    end

    if(nx-ix > 2)
        z = xt(i+2)-xt(i+1);
        s4 = ((zt(i+2,j)-zt(i+1,j))/z-s6)/(s2+z); 
    else
        s4 = 0.0;
    end

    if( (ix <= 0) & (s6*(s6-s2*s4) <= 0.0) ) 
        s4 = s6/s2;
    end

    s1 = x-xt(i);
    s3 = abs(s4*(s2-s1)); 
    z = s3+abs(s5*s1); 

    if(z > 0.0)
        s3 = s3/z;
    end
    if(ix <= 0)
        s3 = 0.0;
    end
    if(nx-ix <= 2)
        s3 = 1.0;
    end

    z = zt(i,j)+s1*s6-s1*(s2-s1)*(s4+s3*(s5-s4));
end