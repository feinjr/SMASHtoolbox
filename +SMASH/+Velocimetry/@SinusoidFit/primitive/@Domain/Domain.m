%
% object=Domain(time,boundary,tolerance)
% 

classdef Domain
    properties (SetAccess=protected)
        Time
        Boundary              
        Tolerance
        Subdomains
        FrequencyCenter
        FrequencyChirp
        TimeLeft
    end
    methods (Hidden=true)
        function object=Domain(varargin)        
            object=reset(varargin{:});            
        end
    end
end