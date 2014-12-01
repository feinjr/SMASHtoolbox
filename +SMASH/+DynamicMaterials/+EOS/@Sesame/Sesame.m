% This class creates objects for analysis and visualization of sesame
% 301 tables. The most direct way of creating a Sesame object is to pass
% the number and name of the sesame file:
%
%   >> object = Sesame('material.ses',neos)
% 
% If only the material number is specified:
%
%   >> object = Sesame(neos)
% 
% the user is prompted to select the sesame file. 
%
% The class stores the tabular points specifying density, temperature,
% pressure, internal energy, and entropy.
%
% Alternatively, the user can directly specify these tabular points:
%   
%   >> object = Sesame(density,temperature,pressure,energy,entropy)
%
% This is often done internally through various methods (isentrope,
% isotherm, etc.) to store a path through phase space.
%
% As a final option, the user can generate a table by specifying a
% reference curve and EOS type. For example, 
%
%   >> object = Sesame('Mie-Gruniesen','cuisentrope',uref,cref,d0,g0,L,cv)
%
% will populate a table based on the isentrope specified by the particle
% velocity, uref, wavespeed, cref, initial density, d0, Gruniesen paramter,
% g0, and specific heat, cv. Units should be the Kerley standard (g/cc,
% GPA, MJ/kg). See CreateSesame for additional details.
%
% See also FileAccess, DataClass, ImportFile, CreateSesame
%
% created April 17, 2014 by Justin Brown (Sandia National Laboraties)
%
classdef Sesame < SMASH.General.DataClass
    properties (SetAccess=?SMASH.General.DataClass) % superclass, class, and subclass access
        SourceFormat = '' % Source format (used in file import/restore)
        Density = [] % Independent array
        Temperature = [] %Independent array
        Pressure =[] %Dependent array
        Energy = [] %Dependent array
        Entropy =[] %Dependent array
    end
    properties (SetAccess={?SMASH.General.DataClass,?SMASH.EOS.Sesame}...% superclass, class, and subclass access
            ,Hidden=true)
        LimitIndex='all' % Region of interest'
    end
    properties
        XLabel='Density' %  XLabel used by "view"
        YLabel='Temperature' %  YLabel used by "view"
        ZLabel='Pressure' %  YLabel used by "view"
        Title='' % Title used by "view"
    end
    properties
        %LineColor='b' % Default line color used by "view"
        %LineStyle='-' % Default line style used by "view"
        %LineWidth=0.5 % Default line width used by "view"
        %Marker='none' % Default marker used by "view"
    end
    %Data class reserved names for special creation options
    properties (Access=?SMASH.General.DataClass,Hidden=true)
            ReservedNames={'Mie-Gruneisen'};
    end
    
        %% hidden methods
    methods (Hidden=true) % constructor
        function object=Sesame(varargin)
            object=object@SMASH.General.DataClass(varargin{:}); % call superclass constructor
        end
    end
    methods (Hidden=true)
        %varargin=makeGridUniform(varargin)
        %varargout=verifyGrid(varargin)
    end
    
    %% protected methods
    methods (Access=protected,Hidden=true)
        varargout=create(varargin);
        varargout=ImportFile(varargin)
        varargout=RestoreFile(varargin)
       
    end

    
    %% property setters
    methods
        function object=set.XLabel(object,value)
           if ischar(value)
               object.DensityLabel=value;
           else
               error('ERROR: GridLabel must be character array');
           end
        end 
        function object=set.YLabel(object,value)
           if ischar(value)
               object.TemperatureLabel=value;
           else
               error('ERROR: GridLabel must be character array');
           end
        end    
        function object=set.ZLabel(object,value)
           if ischar(value)
               object.TemperatureLabel=value;
           else
               error('ERROR: GridLabel must be character array');
           end
        end  
        function object=set.Title(object,value)
            if ischar(value)
                object.Title=value;
            else
                error('ERROR: Title must be character array');
            end
        end
               
    end
    
end