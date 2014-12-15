%
% object=MultipleBound('BoundingCurve');
% object=add(object,ROI); % manually add region of interest
% object=remove(object,index); manually remove region of interest
% object=edit(object); % interactively edit regions of interest

% See also ROI, General.GraphicOptions
classdef MultipleBound
    %%
    properties (SetAccess=protected)
        Allowed = {'BoundingCurve','BoundingLines','BoundingPolygon'} % Allowed boundary types
        BoundArray = {} % Cell array of objects
    end
    properties
        Label = 'Multiple bound object' % Object label (text)
        GraphicOptions  % Graphic options
    end
    %%
    methods (Hidden=true)
        function object=MultipleBound(allowed)
            % handle input
            if (nargin<1) || isempty(allowed)
                allowed=object.Allowed;
            elseif ischar(allowed)
                allowed={allowed};
            end
            assert(iscell(allowed),'ERROR: invalid allowed value');
            for k=1:numel(allowed)
                match=cellfun(@(x) strcmp(allowed{k},x),object.Allowed);
                assert(any(match),'ERROR: invalid allowed value');
            end
            % finish construction
            object.Allowed=allowed;
            if isempty(object.GraphicOptions)
                object.GraphicOptions=SMASH.General.GraphicOptions;
            end
        end
    end
    %% static methods
    methods (Static=true,Hidden=true)
        function object=restore(data)
            object=SMASH.General.GraphicOptions();
            name=fieldnames(data);
            for k=1:numel(name)
                if isprop(object,name{k})
                    object.(name{k})=data.(name{k});
                end
            end
        end
    end
    %% setter methods
    methods
        function object=set.Label(object,value)
            assert(ischar(value),'ERROR: invalid label');
            object.Label=value;
        end
        function object=set.GraphicOptions(object,value)
            if isempty(value)
                object.GraphicOptions=SMASH.General.GraphicOptions;
            elseif isa(value,'SMASH.General.GraphicOptions')
                object.GraphicOptions=value;
            else
                error('ERROR: invalid GraphicOptions value');
            end
        end
    end
end