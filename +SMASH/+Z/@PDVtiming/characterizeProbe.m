% characterizeProbe Characterize probe delay
%
% UNDER CONSTRUCTION
%
% See also PDVtiming
%

%
%
%
function varargout=characterizeProbe(object,measurement,reference)

% manage input
if (nargin<2) || isempty(measurement)
    [filename,pathname]=uigetfile('*.*','Select probe scan file');
    assert(ischar(filename),'ERROR: no file selected');
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
    assert(ischar(fileme),'ERROR: no file selected');
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

end

function [result,RL]=processFile(object,label,filename,record)

% load scan
[~,~,ext]=fileparts(filename);
switch lower(ext)
    case '.obr'
        scan=SMASH.Velocimetry.LUNA(filename);
    case '.sda'
        %try
            scan=SMASH.FileAccess.readFile(filename,'sda',record);
        %catch
        %    return
        %end        
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

label=sprintf('%s%s transit pulse: %.3f ns',...
    upper(label(1)),label(2:end),result);
title(ha(1),label);

% wait for user
hb=ContinueButtons(gui);
waitfor(hb(1));

end