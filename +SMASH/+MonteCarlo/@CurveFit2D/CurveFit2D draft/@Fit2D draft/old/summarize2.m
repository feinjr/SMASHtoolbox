function varargout=summarize(object)

% generate report
report=struct();

report.NumberClouds=object.NumberClouds;
index=1:object.NumberClouds;

report.ActiveClouds=index(logical(object.IsActive));
report.ProcessedClouds=index(logical(object.IsProcessed));

% more to come?

% manage output
if nargout==0
    disp(report);
else
    varargout{1}=report;
end


end