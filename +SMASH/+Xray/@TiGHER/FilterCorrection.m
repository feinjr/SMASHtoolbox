function object = FilterCorrection(object)

if isempty(object.FilterMaterial)
    
else
    NumFilts = length(object.FilterMaterial);
    E = [12398/object.Grid1(end), 12398/object.Grid1(1), 500];
    Tx = ones(E(3),1);
    for i = 1:length(NumFilts)
        OP = SMASH.ColdOpacity(object.FilterMaterial{i},E);
        Tx_temp = CalculateTransmission(OP,object.FilterThickness{i});
        Tx = Tx.*Tx_temp.Data;
    end
    
    object.Transmission = interp1(12398./linspace(E(1),E(2),E(3)),Tx,object.Grid1);
    for i = 1:size(object.Data,1)
        object.Data(i,:) = object.Data(i,:)./object.Transmission;
    end
end
end

