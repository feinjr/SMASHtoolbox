% UPDATEXY Update grid and data of an object
%
% This method combines two signal objects into one
%    >> new=updatexy(object1,object2);
% The new object Grid and Data are determined from object2 while most of
% the other properties are taken from object1. The object history is reset.
%
%
% See also Signal
%
%
% created January 23, 2014 by Justin Brown (Sandia National Laboratories)
%
function object=updatexy(object1, object2)

assert(nargin>1,'ERROR: at least two objects needed')

object=object1; [xupdate yupdate] = limit(object2);
object.Grid=xupdate;
object.Data=yupdate;
object.LimitIndex='all';
%object.Source='updated object';
object=concealProperty(object,'SourceFormat','SourceRecord');
object.ObjectHistory={}; % start fresh

end