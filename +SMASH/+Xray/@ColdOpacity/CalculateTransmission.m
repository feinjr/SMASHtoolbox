function object = CalculateTransmission(object,varargin)
%% object = CalculateTransmission(object,varargin)
% This method calculates the transmission through a material of a specified
% thickness.  If no thickness is provided the user is prompted
% to enter the desired thickness.  The thickness can be provided as an
% optional argument or it can be set in the object's properties.  Object
% must be a ColdOpacity object.
% 
% Created May 30, 2014 by Patrick Knapp (Sandia National Laboratories)
%%
if isempty(varargin) && isempty(object.Settings.Thickness)
    diaTx=SMASH.MUI.Dialog;
    diaTx.Hidden=true;
    diaTx.Name='Calculate Transmission';
    set(diaTx.Handle,'Tag','guiTx');
    
    setappdata(diaTx.Handle, 'thickness', []);
    
    addblock(diaTx,'edit',' Enter Material Thickness in microns',20); % Edit box to input rotation angle
    
    hDone=addblock(diaTx,'button',' Done '); % commits the rotation and grabs the new object
    set(hDone,'Callback',@DoneCallback);
    
    diaTx.Hidden=false;
    uiwait;
    
elseif length(varargin) == 1
    thickness = varargin{1};
elseif ~isempty(object.Settings.Thickness)
    thickness = object.Settings.Thickness;
end

L = thickness;
if numel(L) == 1
    Tx = SMASH.SignalAnalysis.Signal(object.Opacity.Grid,exp(-1e-4*L*object.Opacity.Data*object.Settings.Density));
    Tx.DataLabel = 'Transmission';
    Tx.GridLabel = 'Photon Energy [eV]';
    object.Transmission = Tx;
    object.Settings.Thickness = L;
    
elseif numel(L) > 1
    Tx = zeros(size(object.Opacity.Data));
    label = cell(numel(L)+1,1);
    for n = 1:numel(L)
       Tx(:,n) =  exp(-1e-4*L{n}*object.Opacity.Data(:,n)*object.Settings.Density{n});
       label{n} = [int2str(L{n}),' um ', object.Settings.Material{n}];
    end
    Txtotal = prod(Tx,2);
    object.Transmission = SMASH.SignalAnalysis.SignalGroup(object.Opacity.Grid,[Tx,Txtotal]);
    label{n+1} = 'Total';
    object.Transmission.Legend = label;
end

    function DoneCallback(varargin)
        value=probe(diaTx);
        thickness=sscanf(value{1},'%g');
        delete(diaTx);
    end

end