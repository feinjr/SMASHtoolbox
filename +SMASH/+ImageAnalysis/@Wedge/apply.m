% APPLY Apply Wedge transfer table (object) to an Image (target)
%
%   >> target=apply(object,target);
%
% See also ImageAnalysis, Wedge, analyze
%

% created December 5, 2013 by Tommy Ao (Sandia National Laboratories)
%
%%
function target=apply(object,target)
% handle input
if nargin<2
    error('ERROR: insufficient number of inputs');
end

if ~isa(target,'SMASH.ImageAnalysis.Image')
    error('ERROR: wedge transfer can only be applied to Image objects');
end
    
% map z coordinate using wedge transfer table
target=map(target,'Data','table',object.TransferTable);

target=updateHistory(target);

end