function [ varargout ] = viewproperties( object, varargin)

Narg=numel(varargin);
if Narg == 0
    option = 'Opacity';
elseif Narg == 1
    option = varargin{1};
end

switch option
    case 'Opacity'
        view(object.Opacity);
        set(gca,'XScale','log','YScale','log')
    case 'Transmission'
        view(object.Transmission);
        set(gca,'XScale','log','YScale','linear') 
        
    case 'Attenuation'
        sig = zeros(size(object.Opacity.Data));
        for i = 1:size(object.Opacity.Data,2)
           sig(:,i) =  1./(object.Settings.Density{i}*object.Opacity.Data(:,i));
        end
        signal_group = SMASH.SignalAnalysis.SignalGroup(object.Opacity.Grid, sig);
        signal_group.Legend = object.Opacity.Legend;
        signal_group.GridLabel = object.Opacity.GridLabel;
        signal_group.DataLabel = 'Attenuation Length [cm]';
        view(signal_group)
        set(gca,'XScale','log','YScale','log')
end

if nargout > 0
   varargout{1} = gcf; 
end
end

