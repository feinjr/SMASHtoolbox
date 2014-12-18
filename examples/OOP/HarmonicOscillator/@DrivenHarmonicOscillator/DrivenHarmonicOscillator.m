% under construction
classdef DrivenHarmonicOscillator < SimpleHarmonicOscillator
    %%
    properties       
        DriveFunction
    end
    %%
    methods (Hidden=true)
        function object=DrivenHarmonicOscillator(varargin)
            % nothing to do (yet)
        end
    end
    %%
    methods (Access=protected)
        varargout=calculateDerivatives(varargin)
    end
    %% setters
    methods        
        function object=set.DriveFunction(object,value)
            if ischar(value)
                value=str2func(value);
            end
            assert(isa(value,'function_handle'),...
                'ERROR: invalid DriveFunction');
            object.DriveFunction=value;
        end        
    end
end