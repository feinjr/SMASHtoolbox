% verify Test object readiness
%
% This method determines if a ThermalDiffusion object is ready for
% simulation.
%    >> verify(object);
% Incomplete properties are listed when the method is called with no
% outputs.  The ready status and a list of faulty properties can be
% obtained as follows.
%    >> [ready,fault]=verify(object);
%
% See also ThermalDiffusion, simulate
%

%
% created September 17, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=verify(object)

ready=true;
fault={};

name={'Nodes','Thickness','InitialTemperature',...
    'Conductivity','Diffusivity','InterfaceConductance'};
for n=1:numel(name)
    if strcmp(name{n},'InitialTemperature') && isa(object.(name{n}),'function_handle')
        continue
    elseif any(isnan(object.(name{n})))
        ready=false;
        fault{end+1}=name{n};
    end
end

if nargout==0
    if ready
        fprintf('Object ready for simulation\n');
    else
        fprintf('Object not ready for simulation\n');
        fprintf('   -Check the %s property\n',fault{:});
    end
else
    varargout{1}=ready;
    varargout{2}=fault;
end
    
end