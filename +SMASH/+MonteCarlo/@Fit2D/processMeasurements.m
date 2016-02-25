% processMeasurements Process measurement clouds
%
% *before* analyze is used!
function object=processMeasurements(object,mode)

% manage input
if (nargin<2) || isempty(mode)
    mode='standard';
end
assert(ischar(mode),'ERROR: invalid process mode');
mode=lower(mode);
switch mode
    case {'standard','redo'}
        % valid modes
    otherwise
        error('ERROR: invalid mode')
end

% process measurements
for n=1:object.NumberMeasurements
    if object.isProccessed(n) && strcmpi(mode,'standard')
        continue
    end
    
end


end
% 
% DiagonalMatrix = {} % Cell array of 2x2 diagonal matrices
%         UnitaryMatrix = {} % Cell array of 2x2 unitary matrices
        
        NormalParameters = {} % Cell arrary of binormal parameters [uc vc Lu Lv]
        DensityGrid1 = {} % Cell array of principle grid points (u)
        DensityGrid2 = {} % Cell array of principle grid points (v)
        Density = {} % Cell array of density images