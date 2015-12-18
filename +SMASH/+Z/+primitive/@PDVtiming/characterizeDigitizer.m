% characterizeDigitizer Charaterize digitizer output trigger delay
%
% This method characterizes the delay for the output trigger pulse of a
% digitizer.  Two pieces of information are needed for this calculation:
%   -Time when the output trigger appears on a digitizer input [measurement]
%   -Delay between the output trigger and the digitizer input [offset]
% NOTE: the offset represent electrical cable delay and cannot be negative.
%
% To use this method:
%    delay=characterizeDigitizer(object,measurement,offset);
% The measurement input can be a numeric value or digitizer file.  When a
% digitizer file is passed, the user is prompted to locate the
% characterization pulse; pressing the "Done" button launches an automatic
% refinment of pulse location.
%
% Passing fourth input directly assigns the calculated delay to a
% particular digitizer.
%   [...]=characterizeDigitizer(object,measurement,offset,index);
%
% See also PDVtiming, characterizeTrigger, setupDigitizer
%

%
% created December 3, 2015 by Daniel Dolan (Sandia National Laboratories)
%

function varargout=...
    characterizeDigitizer(object,measurement,offset,index)

% manage input
if (nargin<4) || isempty(index)
    index=[];
else
    assert(isscalar(index) && any(index==object.Digitizer),...
        'EROR: invalid digitizer index');
end

if (nargin<2) || isempty(measurement)
    [filename,pathname]=uigetfile('*.*','Select diagnostic measurement file');
    assert(ischar(filename),'ERROR: no file selected');
    measurement=fullfile(pathname,filename);
end
if ischar(measurement)
    measurement=processFile(object,measurement);    
elseif iscell(measurement)
    measurement=processFile(object,measurement{:});
elseif isnumeric(measurement)
    assert(isscalar(measurement),'ERROR: invalid measurement transit');
else
    error('ERROR: invalid diagnostic delay measurement');
end

if (nargin<3) || isempty(offset)
    offset=0;
end
assert(SMASH.General.testNumber(offset,'positive'),...
    'ERROR: invalid delay offset');

% perform calculation
delay=measurement-offset;

% manage output
if nargout==0
    fprintf('Digitizer delay: %.3f ns\n',delay);    
else
    varargout{1}=delay;
    varargout{2}=measurement;
end

if ~isempty(index)    
    object.DigitizerDelay(index==object.Digitizer)=delay;
end

end

%%
function result=processFile(object,varargin)

% read measurement
measurement=SMASH.SignalAnalysis.Signal(varargin{:});
measurement=regrid(measurement);
measurement=scale(measurement,object.DigitizerScaling);

% calculate measurement derivative
parameters(1)=1; % smoothing order
t=measurement.Grid;
dt=(max(t)-min(t))/(numel(t)-1);
parameters(2)=ceil(object.DerivativeSmoothing/dt);
if parameters(2)<3
    parameters(2)=3;
    warning('SMASH:PDVtiming',...
        'Automatically smoothing over three points');
end

derivative=differentiate(measurement,parameters);
derivative=derivative/max(abs(derivative.Data));
derivative.GraphicOptions.LineColor='r';

% ask user for help
gui=SMASH.MUI.BasicGUI('Name','Digitizer trigger location',...
    'IntegerHandle','off');
ha=addAxes(gui);
set(ha(1),'Box','on')
hb=addButton(gui,' Done ');
set(hb,'Callback','delete(gcbo)');

hl=line('Parent',ha,'Color','k',...
    'XData',measurement.Grid,'YData',measurement.Data);
xlabel('Time (ns)');
ylabel('Signal');

hz=zoom(gui.Figure.Handle);
hz.Motion='horizontal';
hz.Enable='on';

title(ha,'Locate the trigger pulse','FontWeight','normal');
waitfor(hb);

hz.Motion='both';
hz.Enable='off';
xb=xlim(ha);
xlim(xb);

% display selected region
measurement=limit(measurement,xb);
set(hl,'XData',measurement.Grid,'YData',measurement.Data);

derivative=limit(derivative,xb);
ha(2)=addAxes(gui);
set(ha(2),'Visible','off');
hl(2)=line('Parent',ha(2),'Color','r',...
    'XData',derivative.Grid,'YData',derivative.Data); %#ok<NASGU>

linkaxes(ha,'x');
set(ha(1),'YTickMode','auto');
set(ha(2),'YTick',[],...
    'YAxisLocation','right',...
    'YColor',derivative.GraphicOptions.LineColor);

set(gui.AxesPanel,'Children',ha);
set(ha(1),'Color','none');
ylabel(ha(2),'Derivative');

hlink=linkprop(ha,'Position');
setappdata(ha(1),'PositionLink',hlink);

% calculate and display result
[x,y]=limit(derivative);
[~,index]=max(y);
x0=x(index);
keep=abs(x-x0) <= (object.DerivativeSmoothing/2);
result=sum(x(keep).*y(keep))/sum(y(keep));

y0=lookup(measurement,x0);
line('Parent',ha(1),...
    'XData',x0,'YData',y0,'Color','k','Marker','o');

label=sprintf('Digitizer trigger: %.3f ns',result);
title(ha(1),label);

set(ha(2),'Visible','on');

% wait for user
hb=ContinueButtons(gui);
set(gui.Figure.Handle,'WindowStyle','modal');
waitfor(hb(1));
try
    set(gui.Figure.Handle,'WindowStyle','normal');
    refresh(gui);
catch
    % figure was deleted
end

end