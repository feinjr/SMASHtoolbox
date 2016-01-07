% PDVtiming PDV timing analysis
%
% The program launches a graphical user interface for timing analysis of
% PDV systems. 
%    >> PDVtiming;
%
% See also Z
%

%
% created December 22, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=PDVtiming(filename,fontsize)

% manage input
if nargin<1
    filename='';
end

if nargin<2
    fontsize=12;
end
SMASH.System.setDefaultFontSize(fontsize);

% create object
object=SMASH.Z.primitive.PDVtiming(filename,'gui');

% manage output
if nargout>0
    if isdeployed
        varargout{1}=0;
    else
        varargout{1}=object;
    end
end

end