%
% object=MultipleBound('BoundingCurve');
% object=add(object,ROI); % manually add region of interest
% object=remove(object,index); manually remove region of interest
% object=edit(object); % interactively edit regions of interest

classdef MultipleBound
    %%
    properties (SetAccess=protected)
        Allowed = {'BoundingCurve','BoundingLines','BoundingPolygon'} % Allowed boundary types
        BoundArray = {} % Cell array of objects
        Label = 'Multiple bound object'; % Object label (text)
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
        end
    end
end