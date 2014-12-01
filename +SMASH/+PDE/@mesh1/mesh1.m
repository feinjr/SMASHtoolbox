% This class creates one-dimensional mesh objects, which store
% time-dependent information on a static or dynamic set of nodes.  Each
% mesh node has a position and can store multi-dimensional information.%
%
% To create a mesh1 object:
%    >> object=mesh1(time,position,data);
% The input arrays have the following size requirements.
%    -"time" must be a column vector [M x 1]
%    -"position" must be a row vector [1 x N] or compatible 2D array [M x N]
%    -"data" must be a compatible 2D [M x N] or 3D [M x N x D} array
% Static meshes are specified by a [1 x N] position array; dynamic meshes
% require a 2D array to define node positions at each time value. 
% 
%
% See also PDE

%
% created 9/19/2014 by Daniel Dolan (Sandia National Laboratories)
%
classdef mesh1
    properties (SetAccess=protected)      
        Time % Mx1 array
        Node % 1xN array
        Position % 1xN or MxN array 
        Data % MxNxD array      
    end
    methods (Hidden=true)
        function object=mesh1(time,position,data)
            % handle input
            assert(nargin==3,'ERROR: insufficient number of inputs');
            [M,N,D]=size(data);
            assert(M==size(time,1),'ERROR: incompatible time/data array sizes');
            object.Time=time;
            assert(N==size(position,2),'ERROR: incompatible position/data array sizes');
            object.Position=position;            
            object.Node=1:N;
            object.Data=data;
        end
    end    
end