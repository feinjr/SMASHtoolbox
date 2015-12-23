% characterizeProbe Characterize probe delay
%
% This method characterizes the delay for a PDV probe digitizer.  Two
% pieces of information are needed for this calculation:
%   -Transit time for the probe [measurement], including the optical
%   switch.
%   -Transit time for the optical switch only [reference].
% These times describe round-trip transits within a consistent time base,
% such as a optical backscatter reflectometer (OBR).
%
% To use this method:
%    delay=characterizeProbe(object,measurement,reference); 
% The "measurement" and "reference" inputs may be numeric values or names
% of OBR scan files.  If no output is specified, the delay value is printed
% in the command window.
%
% When file names are passed, measurement/reference times are calculated
% from the reflections selected by the user.  Scan files may be in the text
% or binary (*.obr) format used by LUNA system. Archived LUNA objects
% (stored in a *.sda file) can also be used in conjunction with record
% label.  For example:
%    characterizeProbe(object,{filename label},reference); 
% loads the probe measurement from an archived LUNA object.
%
% Passing fourth input directly assigns the calculated delay to a
% particular digitizer.
%   characterizeProbe(object,measurement,reference,index);
%
% See also PDVtiming, setupProbe
%

%
% created December 14, 2015 by Daniel Dolan (Sandia National Laboratories)
%
%
function varargout=characterizeProbe(object,measurement,reference,index)

% manage input
if (nargin<4) || isempty(index)
    index=[];
else
    assert(isscalar(index) && any(index==object.Probe),...
        'EROR: invalid probe index');
end

if (nargin<2) || isempty(measurement)
    [filename,pathname]=uigetfile('*.*','Select probe scan file');
    if isnumeric(filename)
        return
    end
    measurement=fullfile(pathname,filename);
end
if ischar(measurement)
    measurement=processFile(object,'probe',measurement,'');
elseif iscell(measurement)
    measurement=processFile(object,'probe',measurement{:});
elseif isnumeric(measurement)
    assert(isscalar(measurement),'ERROR: invalid measurement transit');
else
    error('ERROR: invalid diagnostic delay measurement');
end

if (nargin<3) || isempty(reference)
    [filename,pathname]=uigetfile('*.*','Select reference scan file');
    assert(ischar(filename),'ERROR: no file selected');
    reference=fullfile(pathname,filename);
end
if ischar(reference)
    reference=processFile(object,'reference',reference,'');    
elseif iscell(reference)
    reference=processFile(object,'reference',reference{:}); 
elseif isnumeric(reference)
    assert(isscalar(reference),'ERROR: invalid reference transit');
else
    error('ERROR: invalid diagnostic delay reference');
end

% perform calculation
delay=(measurement-reference)/2;

% manage output
if nargout==0
    fprintf('Probe delay: %.3f ns\n',delay);    
else
    varargout{1}=delay;
    varargout{2}=measurement;
    varargout{3}=reference;
end

if ~isempty(index)
    object.ProbeDelay(index==object.Probe)=delay;
end

end

%%
function [result,RL]=processFile(object,label,filename,record)

% load scan
[~,~,ext]=fileparts(filename);
switch lower(ext)
    case '.obr'
        scan=SMASH.Velocimetry.LUNA(filename);
    case '.sda'
        scan=SMASH.FileAccess.readFile(filename,'sda',record);
    otherwise % treat as text file
        scan=SMASH.Velocimetry.LUNA(filename);
end

% prompt user for help
gui=SMASH.MUI.BasicGUI;

ha=addAxes(gui);
set(ha,'Box','on','YScale','log');
hl=view(scan,ha); %#ok<NASGU>
xlabel('Transit time (ns)');
ylabel('Optical return (1/mm)')
temp=sprintf('Select %s reflection',label);
title(temp,'FontWeight','normal');

hz=zoom(gui.Figure.Handle);
hz.Motion='horizontal';
hz.Enable='on';

hb=addButton(gui,' Done ');
set(hb,'Callback','delete(gcbo)');
waitfor(hb);

% display the results
xb=xlim(ha);
[result,RL]=locate(scan,object.OBRwidth,xb);
y0=interp1(scan.Time,scan.LinearAmplitude,result);
line(result,y0,'Marker','o','Color','k');

temp={};
temp{end+1}=sprintf('%s%s transit pulse: %.3f ns',...
    upper(label(1)),label(2:end),result);
temp{end+1}=sprintf('Return loss: %.1f dB',RL);
title(ha(1),temp);

% wait for user
hb=ContinueButtons(gui);
waitfor(hb(1));

end