% This class creates objects for analyzing X-Ray Diffraction
% (XRD) measurements.  
%
% XRD objects can be constructed from numeric input:
%     >> object=XRD(Grid1,Grid2,Data); % 2D arrays
% or by loading data from a file.
%     >> object=XRD(filename,format,record); % inputs passed to "readFile" 
% The actual XRD image is stored in the object's Measurement property.
% Settings and results are stored in separate structure arrays.
%
% Angular distribution of diffraction lines and identication of crystal 
% planes [hkl] are the ultimate purposes of the XRD class.  
%
% See also Xray, FileAccess.readFile, ImageAnalysis.Image
%

%
% created August 25, 2015 by Tommy Ao (Sandia National Laboratories)
%
classdef XRD
    %%
    properties
        Measurement % XRD measurement (Image object)        
    end
    properties % (SetAccess=protected)
        Settings % Analysis settings (structure)
        AngularProfile % Analysis result (Signal object)
    end
    %%
    methods (Hidden=true)
        function object=XRD(varargin)
            % default settings
            p=struct();
            p.Center=0;
            p.Radius=0;
            object.Settings=p;
            % manage input
            if (nargin==1) && isobject(varargin{1})
                varargin{1}=SMASH.ImageAnalysis.Image(varargin{1});
                object.Measurement=varargin{1};
            elseif (nargin>0) && ischar(varargin{1})
                temp=SMASH.FileAccess.readFile(varargin{:});
                switch class(temp)
                    case 'SMASH.Xray.XRD'
                        object=temp;
                    otherwise
                        object.Measurement=SMASH.ImageAnalysis.Image(varargin{:});
                end
            else
                object.Measurement=SMASH.ImageAnalysis.Image(varargin{:});
            end
            object.Measurement.Name='XRD Measurement';
            object.Measurement.GraphicOptions.Title='XRD Measurement';
        end
        varargout=partition(varargin);
    end
    %%
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);        
    end   
    %% setters
    methods
        function object=set.Measurement(object,value)
            assert(isa(value,'SMASH.ImageAnalysis.Image'),...
                'ERROR: Measurement property must be a Image object');
            object.Measurement=value;
        end     
    end
end