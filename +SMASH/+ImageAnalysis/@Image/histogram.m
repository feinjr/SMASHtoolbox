% HISTOGRAM Histogram of Image data 
%
% This method provide a graphical representation of the distribution of 
% Image data. Elements in data are sorted into 'nbins' of equally spaced 
% bins along the x-axis between the minimum and maximum values of data.
%
% Usage:
%   >> varargout=histogram(object,varargin);
% The output variables are 'nelements', the number of elements in each bin, 
% and 'xcenters', the centers of each bin.  A default of 10 bins is used,
% but may be changed by input a value for 'nbins'.
% For example, histogram with 100 bins:
%   >> [nelements,xcenters] = histogram(object,100);
% Specifying no output variables create histogram bar plot of object data:
%   >> histogram(object,varargin);
% 
%
% See also IMAGE

% created December 17, 2014 by Tommy Ao (Sandia National Laboratories)

%
function varargout=histogram(object,varargin)

varargout=cell(1,nargout);
[varargout{:}]=hist(object.Data(:),varargin{:});    

end