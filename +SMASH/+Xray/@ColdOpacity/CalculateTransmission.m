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
if isempty(varargin) && isempty(object.Thickness)
    diaTx=SMASH.MUI.Dialog;
    diaTx.Hidden=true;
    diaTx.Name='Calculate Transmission';
    set(diaTx.Handle,'Tag','guiTx');
    
    setappdata(diaTx, 'thickness', []);
    
    addblock(diaTx,'edit',' Enter Material Thickness in microns',20); % Edit box to input rotation angle
    
    hDone=addblock(diaTx,'button',' Done '); % commits the rotation and grabs the new object
    set(hDone,'Callback',@DoneCallback);
    
    diaTx.Hidden=false;
    uiwait;
    
elseif length(varargin) == 1
    thickness = varargin{1};
elseif ~isempty(object.Thickness)
    thickness = object.Thickness;
end

L = thickness;
Tx = exp(-1e-4*L*object.Data*object.Density);
object.Data = Tx;
object.Thickness = L;
object.DataLabel = 'Transmission';
object.Title = ['Transmission: ',num2str(L),' \mum ',object.Material];

    function DoneCallback(varargin)
        value=probe(diaTx);
        thickness=sscanf(value{1},'%g');
        delete(diaTx);
    end

end