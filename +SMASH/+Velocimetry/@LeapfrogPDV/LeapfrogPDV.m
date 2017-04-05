classdef LeapfrogPDV
    %%
    properties (Dependent=true)
        Wavelength
        FrequencyOffset
    end
    properties (SetAccess=protected, Dependent=true)
        Analyzed % indicates if analysis has been performed
        Frequency % Beat frequency values (SignalGroup object)
        FrequencyUncertainty % Beat frequency uncertainties (SignalGroup object)        
        Velocity % Calculated velocity (Signal object)
        VelocityUncertainty % Calculated velocity uncertainty (Signal object)
    end    
    properties (Access=private)
        PrivateWavelength
        PrivateFrequencyOffset
        PrivateAnalyzed = false
        PrivateFrequency
        PrivateFrequencyUncertainty
        PrivateVelocity
        PrivateVelocityUncertainty
    end
    %%
    methods
    end
    %% setters and getters
    methods
        %%
        function object=set.Wavelength(object,value)
            assert(isnumeric(value),'ERROR: invalid Wavelength value');
            if isscalar(value)
                value=repmat(value,size(object.Wavelength));
            end
            assert(numel(value)==numel(object.Wavelength),...
                'ERROR: invalid wavelength value');    
            object.PrivateWavelength=transpose(value(:));
        end
        function value=get.Wavelength(object)
            value=object.PrivateWavelength;
        end
        %%
        function object=set.FrequencyOffset(object,value)
            assert(isnumeric(value),'ERROR: invalid FrequencyOffset value');
            assert(numel(value)==numel(object.FrequencyOffset),...
                'ERROR: invalid FrequencyOffset value');
            object.PrivateFrequencyOffset=transpose(value(:));
        end
        function value=get.FrequencyOffset(object)
            value=object.FrequencyOffset;
        end
        %%
        function object=set.Analyzed(object,value)
            assert(islogical(value),'ERROR: invalid Analyzed value');
            object.PrivateAnalyzed=value;            
        end
        function value=get.Analyzed(object)
            value=object.PrivateAnalyzed;
        end
        %%
        function value=get.Velocity(object)
            if object.Analyzed
                value=object.PrivateVelocity;
            else
                value='(unanalyzed)';
            end
        end
    end
end