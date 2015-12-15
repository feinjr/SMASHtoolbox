% summarize Summarize measurement
%
% This method summarizes the current measurement configuration.
%    summarize(object);
% By default, a report of the available probes/diagnostics/digitizers and
% measurement connections is printed in the command window.  This
% information can also be passed as a cell array to an output argument.
%    report=summarize(object);
%
% See also PDVtiming, saveSession
%

%
% created December 15, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=summarize(object)

report={};

report{end+1}=['Available probes: ' sprintf('%d ',object.Probe)];
report{end+1}=['Available diagnostic channels: ' sprintf('%d ',object.Diagnostic)];
report{end+1}=['Available digitizers: ' sprintf('%d ',object.Digitizer)];
report{end+1}='Connections:';
report{end+1}=sprintf('%10s  %10s  %10s  %10s  %0s',...
    'Probe','Diagnostic','Digitizer','Channel','Label');
for n=1:size(object.MeasurementConnection,1)
    report{end+1}=sprintf('%10d  %10d  %10d  %10d  %0s',...
        object.MeasurementConnection(n,:),object.MeasurementLabel{n}); %#ok<AGROW>
end

% manage output
if nargout==0
    fprintf('%s\n',report{:});
else
    varargout{1}=report;
end

end