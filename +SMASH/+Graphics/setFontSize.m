% setFontSize Set default graphic font size
%
% This function sets the default font size for panels, axes, controls, and
% tables.  Font size is specified as a fraction of the current display
% height.
%    setFontSize(height);
% Internally, fractional height is converted to pixels.
%
% Calling this function without input:
%    setFontSize();
% displays graphic font sizes in the command window.  To restore default
% font sizing:
%    setFontSize('factory'); 
%
% See also Graphics
%

%
% created January 25, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function setFontSize(value)

target={'Uipanel' 'Axes' 'Uicontrol' 'Uitable'};
N=numel(target);

% manage input
if nargin<1
    fprintf('Default font sizes\n');
    width=max(cellfun(@numel,target));
    format=sprintf('%%%ds: %%s\\n',width+1);
    for n=1:N    
        a=sprintf('Default%sFontSize',target{n});
        b=sprintf('Default%sFontUnits',target{n});
        temp=sprintf('%g %s',...
            get(0,a),...
            get(0,b));
        fprintf(format,target{n},temp);
    end
    return
elseif strcmpi(value,'factory') || strcmpi(value,'reset')
    for n=1:N
        a=sprintf('Default%sFontUnits',target{n});
        b=sprintf('Factory%sFontUnits',target{n});
        set(0,a,get(0,b));
        a=sprintf('Default%sFontSize',target{n});
        b=sprintf('Factory%sFontSize',target{n});
        set(0,a,get(0,b));
    end
    return
end

assert(isnumeric(value) && isscalar(value) && value>0 && value<1,...
    'ERROR: invalid height value');

% apply setting
temp=get(0,'ScreenSize');
height=temp(4);
value=value*height;

for n=1:N
    a=sprintf('Default%sFontUnits',target{n});
    b=sprintf('Default%sFontSize',target{n});
    set(0,a,'pixels',b,value);
end