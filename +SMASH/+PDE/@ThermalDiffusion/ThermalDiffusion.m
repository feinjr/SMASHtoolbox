% This class creates object for simulating thermal diffusion in one
% dimension.  Simulations can span an arbitrary number of material layers,
% each with distinct properties and initial temperature.  Layers are
% rigidly fixed in space and kept in contact throughout the simulation.
%
% New objects are created by specifying the number of layers in the
% simulation.
%    >> object=ThermalDiffusion(2); % two layer simulation
% Layer properties can be changed with the "configure" method, but the
% number of layers cannot be modified.  Previously stored objects can be
% loaded from a *.sda file by passing the file name.
%    >> object=ThermalDiffusion('previous.sda',[label]);
% An additional input "label" is required if the archive file contains more
% than one data group.
%
% See also PDE
%

%
% created July 22, 2014 by Daniel Dolan (Sandia National Laboratories)
%
classdef ThermalDiffusion
    %%
    properties (SetAccess=immutable)
        Layers   % number of material layers
        Interfaces % number of internal material interfaces
    end
    properties
        Nodes         % number of nodes in each layer
        Thickness     % layer thicknesses
        InitialTemperature   % initial layer temperatures
        Conductivity  % conductivity functions
        Diffusivity   % diffusivity functions
        InterfaceConductance     % interface conductance functions
        InternalHeating         % internal heating functions
        OutputMode = 'silent' % timing and performance data
        %SimulationResult        % simulation results (table)
    end
    properties (Hidden=true)
        RelTol = 1e-4 % relative solution tolerance
        AbsTol = 1e-4 % absolute solution tolerance
        InitialStep % initial ODE solver time step
        MaxStep % maximum ODE solver time step
    end
    %%
    methods (Hidden=true)
        function object=ThermalDiffusion(varargin)
            assert(nargin>0,'ERROR: insufficient input');
            layers=varargin{1};
            object.Layers=layers;
            object.Interfaces=layers-1;
            %object.Nodes=nan(1,object.Layers);
            object.Nodes=repmat(100,[1 object.Layers]);
            object.Thickness=nan(1,object.Layers);
            object.InitialTemperature=nan(1,object.Layers);
            object.Conductivity=nan(1,object.Layers);
            object.Diffusivity=nan(1,object.Layers);
            object.InterfaceConductance=inf(1,object.Interfaces);
            object.InternalHeating=@(x,t) zeros(numel(x),numel(t));
        end
        varargout=verify(varargin);
    end
    %% set methods
    methods
        function object=set.Nodes(object,value)
            N=numel(object.Nodes);
            if N==0 % initial assignment
                object.Nodes=value;
                return
            end
            assert(isnumeric(value),'ERROR: invalid Nodes input');
            if numel(value)==1
                value=repmat(value,[1 N]);
            end
            assert(numel(value)==N,'ERROR: invalid Nodes input');
            value=round(value);
            assert(all(value>=5),'ERROR: invalid Nodes input');
            object.Nodes=value;
        end
        function object=set.Thickness(object,value)
            N=numel(object.Thickness);
            if N==0 % initial assignment
                object.Thickness=value;
                return
            end
            assert(isnumeric(value),'ERROR: invalid Thickness input');
            if numel(value)==1
                value=repmat(value,[1 N]);
            end
            assert(numel(value)==N,'ERROR: invalid Thickness input');
            assert(all(value>0),'ERROR: invalid Thickness input');
            object.Thickness=value;
        end
        function object=set.InitialTemperature(object,value)
            N=numel(object.InitialTemperature);
            if (N==0) || isa(value,'function_handle') % initial or function handle assignment
                object.InitialTemperature=value;
                return
            end
            assert(isnumeric(value),'ERROR: invalid InitialTemperature input');
            if numel(value)==1
                value=repmat(value,[1 N]);
            end
            assert(numel(value)==object.Layers,'ERROR: invalid InitialTemperature input');
            object.InitialTemperature=value;
        end
        function object=set.Conductivity(object,value)
            N=numel(object.Conductivity);
            if N==0 % initial assignment
                object.Conductivity=value;
                return
            end
            assert(isnumeric(value),'ERROR: invalid Conductivity input');
            if numel(value)==1
                value=repmat(value,[1 N]);
            end
            assert(numel(value)==N,'ERROR: invalid Conductivity input');
            assert(all(value>0),'ERROR: invalid Conductivity input');
            object.Conductivity=value;
        end
        function object=set.Diffusivity(object,value)
            N=numel(object.Diffusivity);
            if N==0 % initial assignment
                object.Diffusivity=value;
                return
            end
            assert(isnumeric(value),'ERROR: invalid Diffusivity input');
            if numel(value)==1
                value=repmat(value,[1 N]);
            end
            assert(numel(value)==N,'ERROR: invalid Diffusivity input');
            assert(all(value>0),'ERROR: invalid Diffusivity input');
            object.Diffusivity=value;
        end
        function object=set.InterfaceConductance(object,value)
            N=numel(object.InterfaceConductance);
            if N==0 % initial assignment
                object.InterfaceConductance=value;
                return
            end
            assert(isnumeric(value),'ERROR: invalid InterfaceConductance input');
            if numel(value)==1
                value=repmat(value,[1 N]);
            end
            assert(numel(value)==N,'ERROR: invalid InterfaceConductance input');
            assert(all(value>=0),'ERROR: invalid InterfaceConductance input');
            object.InterfaceConductance=value;
        end
        function object=set.InternalHeating(object,value)
            assert(isa(value,'function_handle'),...
                'ERROR: invalid InternalHeating input');
            object.InternalHeating=value;
        end
        function object=set.RelTol(object,value)
            assert(SMASH.General.testNumber(value,'positive'),...
                'ERROR: invalid RelTol value');
            object.RelTol=value;
        end
        function object=set.AbsTol(object,value)
            assert(SMASH.General.testNumber(value,'positive'),...
                'ERROR: invalid RelTol value');
            object.AbsTol=value;
        end
        function object=set.InitialStep(object,value)
            if isempty(value)
                object.InitialStep=[];
                return
            end
            assert(SMASH.General.testNumber(value,'positive'),...
                'ERROR: invalid InitialStep value');
            object.InitialStep=value;
        end
        function object=set.MaxStep(object,value)
            if isempty(value)
                object.MaxStep=[];
                return
            end
            assert(SMASH.General.testNumber(value,'positive'),...
                'ERROR: invalid MaxStep value');
            object.MaxStep=value;
        end
        function object=set.OutputMode(object,value)
            assert(ischar(value),'ERROR: invalid OutputMode');
            switch lower(value)
                case 'silent'
                    object.OutputMode='silent';
                case 'verbose'
                    object.OutputMode='verbose';
            end
        end
    end
end
