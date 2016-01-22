% calculateFontSize Calculate font size as a fraction display height
%
% This function calculates font size (in pixels) as a fraction of the
% display height.
%    value=calculateFontSize(fraction); % default input is 0.01
% In general, font sizes should be 1-2% of the display height.  Smaller
% sizes are difficult to read, while larger sizes (especially more than
% 5-10%) significant amounts of screen space
%
% See also System
%

%
% created January 21, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function result=calculateFontSize(fraction)

% manage input
if (nargin<1) || isempty(fraction)
    fraction=0.01;
end

assert(isnumeric(fraction) && isscalar(fraction) && fraction>0 && fraction<1,...
    'ERROR: invalid fraction value');

% perform calculation
temp=get(0,'ScreenSize');
height=temp(4);
result=fraction*height;

end