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
end

if nargout > 0
   varargout{1} = gcf; 
end
end

