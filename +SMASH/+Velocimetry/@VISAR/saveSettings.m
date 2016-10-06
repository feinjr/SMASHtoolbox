% SAVESETTINGS - Save the Settings for a VISAR object
%
% This method saves the settings of the current VISAR object to a file
%     >> object=saveSettings(object,filename)
%
% The default filename is 'VISAR_Settings.txt'
%
% created March 21, 2016 by Paul Specht (Sandia National Laboratories)

function object=saveSettings(object,filename)

%manage input
if nargin < 2
     error('ERROR:  Invalid saveSettings Input.  Must Define File Name.');
end
assert(ischar(filename),...
    'ERROR: File Name Invalid');

% Open the specified file and begin generating the file text
fid=fopen(filename,'wt');
offset=repmat(' ',[1 3]);
message{1} = '% VISAR Analysis Configuration';
message{2} = ['% Generated ' datestr(now)];
message{3} = '';
message{4} = ['Type               =',offset,'{',object.Type,'}'];
message{5} = ['Label              =',offset,'{',object.Label,'}'];
message{6} = ['Notes              =',offset,'{',object.Notes,'}'];
message{7} = ['Timeshifts         =',offset,'{',num2str(object.TimeShifts),'}'];
message{8} = ['VerticalOffsets    =',offset,'{',num2str(object.VerticalOffsets),'}'];
message{9} = ['VerticalScales     =',offset,'{',num2str(object.VerticalScales),'}'];
message{10} = ['VPF                =',offset,'{',num2str(object.VPF),'}'];
message{11} = ['InitialVelocity    =',offset,'{',num2str(object.InitialVelocity),'}'];
message{12} = ['EllipseParameters  =',offset,'{',num2str(object.EllipseParameters),'}'];
message{13} = ['ReferenceRegion    =',offset,'{',num2str(object.ReferenceRegion),'}'];
message{14} = ['ExperimentalRegion =',offset,'{',num2str(object.ExperimentalRegion),'}'];
for k=1:size(object.Jumps,1)
    if k == 1
        message{15} = ['Jumps              =',offset,'{',num2str(object.Jumps(k,:)),'}'];
    else
        message{15} = [message{15},',{',num2str(object.Jumps(k,:)),'}'];
    end
end

% Write the entire message to the file
fprintf(fid,'%s\n',message{:});

% Close the configuration file
fclose(fid);
