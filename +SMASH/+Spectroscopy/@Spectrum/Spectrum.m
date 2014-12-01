% This class creates Spectrum objects for spectroscopy analysis.
%
% The most direct way of creating a Spectrum object is to pass two
% numerical arrays.
%    >> object=Spectrum(x,y);
% The first input is the grid (independent) array, while the second input
% is the data (dependent) array.
%
% See also Spectroscopy
%

% created April 1, 2014 by Tommy Ao (Sandia National Laboratories)
%
classdef Spectrum < SMASH.SignalAnalysis.Signal
    %%
    properties
        GridType = 'Wavelength' % Independent array type (Wavelength or Energy)
    end
    
    %% constructor
    methods (Hidden=true)
        function object=Spectrum(varargin)
            object=object@SMASH.SignalAnalysis.Signal(varargin{:});
            object.Name='Spectrum object';
            object.GridLabel='Wavelength (nm) ';
            object.GridType='Wavelength';
            %object=concealProperty(object,'SourceFormat','SourceRecord',...
            %    'LineColor','LineStyle','LineWidth','Marker','Precision',...
            %    'LimitIndex');
        end
    end
    %% protected methods
    methods (Access=protected,Hidden=true)
        varargout=create(varargin);
        varargout=import(varargin);
    end
    %% property setters
    methods
        function object=set.GridType(object,value)
            assert(ischar(value),'ERROR: invalid GridType');
            if ~strcmp(object.GridType,value)
                switch value % spectral density conversion?
                    case 'Energy' % convert to Energy (eV)
                        object.Grid=1.239997./(object.Grid/1e3);
                        object.GridLabel='Energy (eV) ';
                    case 'Wavelength' % convert to Wavelenghth (nm)
                        object.Grid=1.239997./object.Grid*1e3;
                        object.GridLabel='Wavelength (nm) ';
                end
                object.GridType=value;
            else
                % do nothing
            end
        end
    end
end
