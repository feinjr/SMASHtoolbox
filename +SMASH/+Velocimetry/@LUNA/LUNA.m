% This class creates objects for displaying and analyzing fiber scans from
% a LUNA optical backscatter reflectomer.  LUNA objects are created from a
% source file:
%     >> object=LUNA(filename);
% Binary (*.obr) and text file formats are both accepted.
%
%
% See also Velocimetry
%

%
% created April 29, 2015 by Daniel Dolan (Sandia National Laboratories)
%
classdef LUNA
    properties (SetAccess=protected)
        SourceFile % LUNA scan file
        FileHeader % Scan file header
        IsModified % Logical indicator of modified time axes 
        Time % Transit time [nanoseconds]
        %TimeMode = 'RoundTrip' % Timing mode: 'SinglePass' or 'RoundTrip'
        LinearAmplitude % Fractional signal per unit length [1/millmeters]
    end
    %%
    methods (Hidden=true)
        function object=LUNA(filename)
            if nargin<1
                filename='';
            elseif strcmp(filename,'-empty') % empty object
                return
            end
            object=read(object,filename);
        end
    end    
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
end