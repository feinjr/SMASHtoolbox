% SUMMARIZE Summarize Grid and Data information
% 
% This method provides a statistical summary of the information stored in a Signal
% object.
%    >> result=summary(object); 
% The output "result" is a structure describing the Grid and Data contained
% in the limited region.
%
% See also Signal, limit
%

%
% created May 1, 2014 by Daniel Dolan (Sandia National Laboratories)
% revised July 11, 2014 by Daniel Dolan
%    -Added Grid summary as a sub-structure
%    -Moved Data summary to a sub-structure
%
function result=summarize(object)

% extract Data from limited region
[Grid,Data]=limit(object);
Data=Data(:);

% summarize Grid
result.Grid.Min=min(Grid);
result.Grid.Max=max(Grid);
result.Grid.Range=result.Grid.Max-result.Grid.Min;
result.Grid.Center=mean(Grid);

% summarize Data
result.Data.Mean=mean(Data);
result.Data.Std=std(Data);
result.Data.Min=min(Data);
result.Data.Max=max(Data);
result.Data.Median=median(Data);

end