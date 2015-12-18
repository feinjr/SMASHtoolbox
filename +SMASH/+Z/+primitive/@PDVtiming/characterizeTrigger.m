% characterizeTrigger Charaterize digitizer trigger time
%
% This method characterizes the trigger time of a specified digitizer as
% recorded by ZDAS.
%    result=characterize(object,filename,record);
% The second input is the name of a ZDAS (*.hdf), PFF (*.pff), or text (all
% other extensions) where the digitizer's output trigger is recorded.  The
% third record is the text label for the trigger signal (useful for *.hdf
% and *.pff files).
% 
% Calling this method generates a new figure with the output trigger
% measurement.  The user is prompted to zoom into the trigger pulse to
% assist the characterization.  Pressing the "Next" button shows the
% characterization results.
%
% Passing fourth input directly assigns the calculated delay to a
% particular digitizer.
%   [...]=characterizTrigger(object,measurement,offset,index);
%
% See also PDVtiming, characterizeDigitizer, setupDigitizer
%

%
% created December 2, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=characterizeTrigger(object,filename,record,index)

% manage input
if (nargin<4) || isempty(index)
    index=[];
else
    assert(isscalar(index) && any(index==object.Digitizer),...
        'EROR: invalid digitizer index');
end

if (nargin<2) || isempty(filename)
    [filename,pathname]=uigetfile('*.*','Select digitizer trigger file');
    assert(ischar(fileme),'ERROR: no file selected');
    filename=fullfile(pathname,filename);
end
assert(ischar(filename),'ERROR: invalid file name');
assert(exist(filename,'file')==2,'ERROR: requested file does not exist');

if (nargin<3) || isempty(record)
    record='DM_PDV1';    
end
assert(ischar(record),'ERROR: invalid trigger record');

% read trigger measurement
[~,~,ext]=fileparts(filename);
switch lower(ext)
    case '.hdf'     
        measurement=processFile(object,filename,'zdas',record);
    case '.pff'
        report=SMASH.FileAccess.probeFile(filename);
        for n=1:numel(report)
            if strcmpi(record,strtrim(report(n).Title))
                record=n;
                break
            end
        end
        assert(isnumeric(record),...
            'ERROR: requested digitizer signal not found');
        measurement=processFile(object,filename,'pff',record);
    otherwise
        measurement=processFile(object,filename,'column');
end

% perform calculation
trigger=measurement;

% manage output
if nargout==0
    fprintf('Digitizer trigger: %.3f ns\n',trigger);    
else
    varargout{1}=trigger;
end

if ~isempty(index)
    object.DigitizerTrigger(index==object.Digitizer)=trigger;
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
        'Smooth duration is too small--automatically smoothing over three points');
end

derivative=differentiate(measurement,parameters);
derivative=derivative/max(abs(derivative.Data));
derivative.GraphicOptions.LineColor='r';

% ask user for help
gui=SMASH.MUI.BasicGUI('Name','Digitizer trigger location');
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
waitfor(hb(1));
waitfor(hb(1));
try
    set(gui.Figure.Handle,'WindowStyle','normal');
    refresh(gui);
catch
    % figure was deleted
end

end