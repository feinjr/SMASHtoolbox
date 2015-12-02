function [result,measurement,derivative]=characterizeTrigger(object,index,filename)

% manage input
if (nargin<2) || isempty(filename)
    % prompt user to select file
end
assert(ischar(filename),'ERROR: invalid file name');
assert(exist(filename,'file')==2,'ERROR: requested file does not exist');

% read trigger measurement
[~,~,ext]=fileparts(filename);
switch lower(ext)
    case '.hdf'
        record=sprintf('DM_PDV%d',index);
        try
            measurement=SMASH.SignalAnalysis.Signal(filename,'zdas',record);
        catch
            error('ERROR: requested digitizer signal not found');
        end
    case '.pff'
        record=sprintf('DM_PDV%d',index);
        report=SMASH.FileAccess.probeFile(filename);
        for n=1:numel(report)
            if strcmpi(record,report(n).Title)
                record=n;
                break
            end
        end
        assert(isnumeric(record),...
            'ERROR: requested digitizer signal not found');
        measurement=SMASH.SignalAnalysis.Signal(filename,'pff',record);
    otherwise
        measurement=SMASH.SignalAnalysis.Signal(filename,'column');
end
measurement=regrid(measurement);
measurement.GridLabel='Time';
measurement.DataLabel='Measurement';

% calculate measurement derivative
parameters(1)=1; % smoothing order
t=measurement.Grid;
dt=(max(t)-min(t))/(numel(t)-1);
parameters(2)=ceil(object.SmoothDuration/dt);
assert(parameters(2)>=3,'ERROR: smooth duration is too small');

derivative=differentiate(measurement,parameters);
derivative=derivative/max(abs(derivative.Data));

% ask user for help
hl=view(measurement);
ha=ancestor(hl,'axes');
fig=ancestor(hl,'figure');
set(fig,'NumberTitle','off','Name','Locate trigger pulse');
hz=zoom(fig);
hz.Motion='horizontal';
hz.Enable='on';

title('Use zoom/pan to locate trigger pulse',...
    'FontWeight','normal');
hc=uicontrol('Style','pushbutton','String',' next ',...
    'Callback','delete(gcbo)');
waitfor(hc);
xb=xlim(ha);

delete(ha);
hz.Motion='both';
hz.Enable='off';
[ha,hl(1),hl(2)]=plotyy(...
    measurement.Grid,measurement.Data,derivative.Grid,derivative.Data);
set(hl(1),'Color','k');
set(ha(1),'YColor','k');
set(hl(2),'Color','r');
set(ha(2),'YColor','r');
linkaxes(ha,'x')
xlim(ha(1),xb);
xlabel('Time');
ylabel(ha(1),'Measurement');
ylabel(ha(2),'Derivative');
set(ha,'YLimMode','auto');
set(ha(1),'YTickMode','auto');
set(ha(2),'YTick',[]);

hc=uicontrol('Style','pushbutton','String',' done ',...
    'Callback','delete(gcbo)');
%waitfor(hc);

%close(fig);

result=nan;

end