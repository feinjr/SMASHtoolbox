% HIST Histogram of Image data 
%
% This method provide a graphical representation of the distribution of 
% Image data. Elements in data are sorted into 'nbins' of equally spaced 
% bins along the x-axis between the minimum and maximum values of data.
%
% Usage:
%   >> varargout=hist(object,varargin);
% The output variables are 'nelements', the number of elements in each bin, 
% and 'xcenters', the centers of each bin.
% Specifying no output variables create histogram bar plot of object data:
%   >> hist(object,varargin);
% 
%
% See also IMAGE

% created December 16, 2014 by Tommy Ao (Sandia National Laboratories)

%
function varargout=hist(object,varargin)

varargout=cell(1,nargout);
[varargout{:}]=hist(object.Data(:),varargin{:});    

end