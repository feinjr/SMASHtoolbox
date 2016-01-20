% AxesInset : create an axes inset 
%
% This function creates an axes inset, a small copy of the original axes
% that emphasizes a particular region of interest.  The horizontal and
% vertical limits of the inset and its position (with respect) to the
% original can be specified.
%    AxesInset(haxes,name,value,...);
% If the original axes handle (haxes) is omitted, the function defaults to
% the current axes.  Valid setting names include:
%   'xbound'     : horizontal bounds of the inset
%   'ybound'     : vertical bounds of the inset
%   'position'   : inset axes position [x0 y0 Lx Ly] relative to the original
%
% Inset bounds can be controlled by click/dragging on the rectangle in the
% original axes.  To manually adjust the bounds or the inset axes position,
% right-click on the rectangle and select "Position inset".  The function
% also returns a custom object for advanced inset control.
%    object=AxesInset(...);
%    object.XBound=[a b];
%    update(object);
%
% See also Graphics, SMASH.Graphics.primitive.AxesInset
%

%
% created January 19, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=AxesInset(varargin)

object=SMASH.Graphics.primitive.AxesInset(varargin{:});

% manage output
if nargout>0
    varargout{1}=object;
end

end