% characterizeDiagnostic Charaterize diagnostic delay
%
% This method characterizes the diagnostic delay for a single PDV channel.
% Diagnostic delay is the transit time between optical input at the PDV
% to the electrical input at the digitizer.  Three pieces of information
% are needed for this calculation:
%   -Optical pulse time through the PDV channel (measurement).
%   -Electrical pulse time through a reference detector (reference).
%   -Group delay for the reference detector (offset).
% Pulse times must be obtained from a common time base, i.e. the digitizer.
%  NOTE: offset is combination of optical/electrical transit (fiber,
%  detector/cable) and cannot be negative.
%
% To use this method:
%    delay=characterizeDiagnostic(object,measurement,reference,offset);
% Measurement and reference inputs can be numeric vales, digitizer files
% where such information is available, or any combination of the two.  When
% digitizer files are passed, the user is prompted to locate the
% characterization pulse; pressing the "Done" button launches an automatic
% refinment of pulse location.
%
% See also PDVtiming
%

%
% created December 3, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=...
    characterizeDiagnostic(object,measurement,reference,offset)

% manage input
if (nargin<2) || isempty(measurement)
    [filename,pathname]=uigetfile('*.*','Select diagnostic measurement file');
    assert(ischar(filename),'ERROR: no file selected');
    measurement=fullfile(pathname,filename);
end
if ischar(measurement)
    [measurement,MeasurementReport]=...
        processFile(object,'measurement',measurement);    
elseif iscell(measurement)
    [measurement,MeasurementReport]=...
        processFile(object,'measurement',measurement{:});
elseif isnumeric(measurement)
    assert(isscalar(measurement),'ERROR: invalid measurement transit');
    MeasurementReport=struct();
else
    error('ERROR: invalid diagnostic delay measurement');
end

if (nargin<3) || isempty(reference)
    [filename,pathname]=uigetfile('*.*','Select diagnostic reference file');
    assert(ischar(fileme),'ERROR: no file selected');
    reference=fullfile(pathname,filename);
end
if ischar(reference)
    [reference,ReferenceReport]=...
        processFile(object,'reference',reference);    
elseif iscell(reference)
    [reference,ReferenceReport]=...
        processFile(object,'reference',reference{:});
elseif isnumeric(reference)
    assert(isscalar(reference),'ERROR: invalid reference transit');
    ReferenceReport=struct();
else
    error('ERROR: invalid diagnostic delay reference');
end

if (nargin<4) || isempty(offset)
    offset=0;
end
assert(SMASH.General.testNumber(offset,'positive'),'ERROR: invalid delay offset');

% perform calculation
delay=measurement-reference+offset;

% manage output
if nargout==0
    fprintf('Diagnostic delay: %.3f ns\n',delay);    
else
    varargout{1}=delay;
    varargout{2}=MeasurementReport;
    varargout{3}=ReferenceReport;
end

end

function [result,report]=processFile(object,label,varargin)

% read file
measurement=SMASH.SignalAnalysis.Signal(varargin{:});
measurement=regrid(measurement);
measurement=scale(measurement,object.DigitizerScaling);

% ask user for help
gui=SMASH.MUI.BasicGUI('Name','Pulse location');
ha=addAxes(gui);
set(ha(1),'Box','on')
hl=line('Parent',ha,'Color','k',...
    'XData',measurement.Grid,'YData',measurement.Data);
xlabel('Time (ns)');
ylabel('Signal');

hz=zoom(gui.Figure.Handle);
hz.Motion='horizontal';
hz.Enable='on';
title(ha,sprintf('Locate the %s pulse',label),...
    'FontWeight','normal');
hb=addButton(gui,' Done ');
set(hb,'Callback','delete(gcbo)');
waitfor(hb);

Mxb=xlim(ha);
measurement=limit(measurement,Mxb);
report=locate(measurement);

% display the results
[x,y]=limit(measurement);
set(hl,'XData',x,'YData',y);
line(x,report.Fit,'Color','k','LineStyle','--');
axis(ha,'auto');

result=report.Location;
label=sprintf('%s%s pulse location: %.3f ns',...
    upper(label(1)),label(2:end),result);
title(ha(1),label);

y0=lookup(measurement,result);
line(result,y0,'Marker','o','Color','k');

% pause for user
hb=ContinueButtons(gui);
waitfor(hb(1));

end