% EXPORT Export object to a basic data file
%
% This method exports a VelocityTransfer object's Result signal
%
%    >> export(object,filename);
%
% See also VelocityTransfer, Signal
%
% created March 30, 2105 by Justin Brown (Sandia National Laboratories) 

function export(object,filename,varargin)

export(object.Results,filename,varargin);

end