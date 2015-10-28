% calculateDistance Determine minimum distance(s)
%
% This method calculations the minimum distances between a LineSegments
% object and set of origin points.
%     >> [D2,location]=calculateDistance(object,origin);
% The second input, "origin", is an array of coordinates.  Each row in this
% array defines a point from which a distnace calculation originates.  The
% number of columns in the array MUST match the dimensionality of the
% LineSegments object.  For example, a Lx2 origin array performs L distance
% calculations for a two-dimensional LineSements object.
%
% Two outputs are generated in the minimum distance calculation.  The first
% output, "D2", is an array of minimum square distances.
% The second output, "location", is an array of minimum-distance
% coordinates on the LineSegments object.  Both outputs have the same
% number of rows as the "origin" input.  The first output is a column
% array, while second has the same number of columns as the origin array.
%
% Calculations in this method use the Mahalanobis distance.
%     D2= u' * Q * u
% The vector u points from the specified origin(s) to points on the
% LineSegments object; these points are selected to minimize the value(s)
% of D2.  The matrix Q is the pseudoinverse of a covariance matrix for the
% origin array.  By default, the identity matrix is used, so the
% Mahalanobis distance is equivalant to geometric distance.  A shared
% covariance array can be specified for all origin points in the distance
% calculation.
%     >> [...]=calculateDistance(object,origin,matrix);
% The input "matrix" must be a square array consistent with the object's
% dimensionality, e.g. a 2x2 matrix is used for two-dimensional systems.
% The diagonal elements of the matrix are variances for each variable,
% while the off-diagonal elements are cross variances between variables.
% For example, matrix(1,1) is the variance for the first variable and
% matrix(1,2) is the covariance between the first and second variable.
% Diagonal elements must always be greater than zero, and off-diagonal
% elements must be symmetric.
%
% See also LineSegments
%

%
% created October 22, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function [D2,location]=calculateDistance(object,origin,matrix)

% manage input
assert(nargin>=2,'ERROR: insufficient input');

if isa(origin,'SMASH.MonteCarlo.Support.LineSegments')
    origin=origin.Coordinates;
end
assert(ismatrix(origin),'ERROR: invalid origin input');
assert(size(origin,2)==object.NumberDimensions,...
    'ERROR: inconsistent dimensionality');

if (nargin<3) || isempty(matrix)
    matrix=eye(object.NumberDimensions);
end
assert(ismatrix(matrix),'ERROR: invalid covariance matrix');
assert(all(diag(matrix)>0),...
    'ERROR: diagonal elemnents of the covariance matrix must be greater than zero');
change=matrix-transpose(matrix);
change=abs(bsxfun(@rdivide,change,diag(matrix)));
assert(all(change(:))<1e-9,'ERROR: covariance matrix must be symmetric ')


% prepare for calculation
Q=pinv(matrix);
Norigin=size(origin,1);
D2=inf(Norigin,1);
location=nan(object.NumberDimensions,Norigin);

ref=transpose(object.Segments(:,:,1));
Delta=transpose(object.Segments(:,:,3));
origin=transpose(origin);

crop= ~strcmpi(object.BoundaryType,'projected');

% 2D calculation
a=Q(1,1);
bc=(Q(1,2)+Q(2,1))/2;
d=Q(2,2);
vector=nan(2,1);
for m=1:Norigin
    for n=1:object.NumberSegments
        dx=ref(1,n)-origin(1,m);
        dy=ref(2,n)-origin(2,m);
        numerator=...
            a*dx*Delta(1,n)+bc*(dx*Delta(2,n)+dy*Delta(1,n))...
            +d*dy*Delta(2,n);
        denominator=a*Delta(1,n)^2+2*bc*Delta(1,n)*Delta(2,n)...
            +d*Delta(2,n)^2;
        t=-numerator/denominator;
        if t<0 
            if (n>1) || crop
                t=0;                           
            end           
        elseif t>1
            if (n<object.NumberSegments) || crop
                t=1;
            end
        end 
        xt=ref(1,n)+t*Delta(1,n);
        yt=ref(2,n)+t*Delta(2,n);
        vector(1)=xt-origin(1,m);
        vector(2)=yt-origin(2,m);
        %new=transpose(vector)*Q*vector;
        new=a*vector(1)^2+2*bc*vector(1)*vector(2)+d*vector(2)^2;
        if new<D2(m)
            D2(m)=new;
            location(1,m)=xt;
            location(2,m)=yt;
        end
    end
end

location=transpose(location);

end