function object = CalculateOpacity(object)
%
%%
material_in = object.Settings.Material;
if ischar(material_in);  material = {material_in};
else material = material_in; end

num_elems = numel(material);

Earray = object.Settings.Energy;
hnu = linspace(Earray(1),Earray(2),Earray(3));

op = importdata('+SMASH/+Xray/@ColdOpacity/private/Opacities.xlsx');
elements = op.textdata;
kappa_interp = zeros(Earray(3),num_elems);
density = cell(num_elems,1);

for n = 1:numel(material)
    for i = 2:length(elements)
        if strcmpi(material{n}, elements{1,i}); idx = i; end
    end
    
    if isempty(object.Settings.Density)
        density{n} = op.data(1,idx);
    end
    
    kappa = op.data(2:end,idx);
    kappa_interp(:,n) = interp1(op.data(2:end,1), kappa, hnu);
end

if num_elems == 1
    object.Opacity = SMASH.SignalAnalysis.Signal(hnu,kappa_interp);
    object.Opacity.Name = material{1};
    object.Settings.Density = density{1};
elseif num_elems > 1
    object.Opacity = SMASH.SignalAnalysis.SignalGroup(hnu,kappa_interp); 
    object.Opacity.Legend = material;
    object.Settings.Density = density;
end
object.Opacity.GridLabel = 'Photon Energy [eV]';
object.Opacity.DataLabel = 'Opacity [cm^2/g]';


end
