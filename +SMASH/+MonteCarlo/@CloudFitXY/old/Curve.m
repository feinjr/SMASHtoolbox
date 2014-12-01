%
%    >> object=Curve();
%    >> object=Curve(cloud1,cloud2,...);
%    >> object=Curve(array);

classdef Curve < SMASH.General.DataClass
    %%
    properties (SetAccess=protected)
        Clouds % cell array of Cloud objects
        Active % Logical array indicating active Clouds
    end
    properties
        Iterations=100 % Number of Monte Carlo iterations
        XLabel='x'
        YLabel='y'
    end    
    %% constructor
    methods (Hidden=true)
        function object=Curve(varargin)
            object=object@SMASH.General.DataClass([]);
            if nargin>0
                object=add(object,varargin{:});
            end                        
        end
    end
  %% protected methods
  methods % change to protected at some point
      varargout=normalize(varargin);
  end
  
end