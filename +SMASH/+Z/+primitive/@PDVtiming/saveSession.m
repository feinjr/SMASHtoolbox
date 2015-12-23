% saveSession Save timing information to a session file
%
% This method saves PDV timing information to a session file. Session files
% use tab-separated values for easy display/modification in a spreadsheet
% program.  Session files can also be loaded in future analysis.
%
% To save timing information to a file:
%    saveSession(object,filename);
% If no file name is specified, the user will be prompted to select a file.
%
% See also PDVanalysis, loadSession
%

%
% created December 14, 2015 by Daniel Dolan
%
function saveSession(object,filename)

% manage input
if (nargin<2) || isempty(filename)
    if isempty(object.SessionFile)
        [filename,pathname]=uiputfile('*.*','Select session file');
    else
        [filename,pathname]=uiputfile('*.*','Select session file',...
            object.SessionFile);
    end
    if isnumeric(filename)
        return
    end
    filename=fullfile(pathname,filename);
    object.SessionFile=filename;
end
assert(ischar(filename),'ERROR: invalid session file name');

% open session file
try
    fid=fopen(filename,'w');
    CloseFile=onCleanup(@() fclose(fid));
catch
    error('ERROR: unable to create session file');
end

% header
fprintf(fid,'Experiment:\n');
fprintf(fid,'\t%s\n',object.Experiment);
N=size(object.Comment,1);
for n=1:N
    fprintf(fid,'\t%s\n',object.Comment(n,:));
end

fprintf(fid,'\n\tNOTE: All times are in nanoseconds\n');
fprintf(fid,'\n');

% connections
fprintf(fid,'Connections:\n');
fprintf(fid,'\tProbe\tDiagnostic\tDigitizer\tChannel\tCorrection\tLabel\n');
[result,connect,label]=analyze(object);
N=numel(result);
for n=1:N
    fprintf(fid,'\t%d\t%d\t%d\t%d',connect(n,:));
    fprintf(fid,'\t%.3f',result(n));
    fprintf(fid,'\t%s\n',label{n});
end

fprintf(fid,'\n');

% digitizer settings
fprintf(fid,'Digitizer:\n');
fprintf(fid,'\tIndex\tDelay\tTrigger\t\n');
N=numel(object.Digitizer);
for n=1:N
    fprintf(fid,'\t%d\t%.3f\t%.3f\n',...
        object.Digitizer(n),object.DigitizerDelay(n),...
        object.DigitizerTrigger(n));
end

fprintf(fid,'\n');

% diagnostic settings
fprintf(fid,'Diagnostic:\n');
fprintf(fid,'\tIndex\tDelay\n');
N=numel(object.Diagnostic);
for n=1:N
    fprintf(fid,'\t%d\t%.3f\n',...
        object.Diagnostic(n),object.DiagnosticDelay(n));
end

fprintf(fid,'\n');

% probe settings
fprintf(fid,'Probe:\n');
fprintf(fid,'\tIndex\tDelay\n');
N=numel(object.Probe);
for n=1:N
    fprintf(fid,'\t%d\t%.3f\n',object.Probe(n),object.ProbeDelay(n));
end

fprintf(fid,'\n');

% analysis parameters
fprintf(fid,'Parameters:\n');
fprintf(fid,'\tDigitizerScaling = %e\n',object.DigitizerScaling);
fprintf(fid,'\tDerivativeSmoothing = %g ns\n',object.DerivativeSmoothing);
fprintf(fid,'\tFiducialRange = %g ns\n',object.FiducialRange);
fprintf(fid,'\tOBRwidth =  %g ns\n',object.OBRwidth);

fprintf(fid,'\n');

% digitizer channel settings
fprintf(fid,'Digitizer channels:\n');
fprintf(fid,'\tDigitizer\tChannel\tRelative Delay\n');
N=numel(object.DigitizerChannel);
for n=1:N
    M=numel(object.DigitizerChannel{n});
    for m=1:M
        fprintf(fid,'\t%d\t%d\t%.3f\n',...
            object.Digitizer(n),object.DigitizerChannel{n}(m),...
            object.DigitizerChannelDelay{n}(m));
    end
end
fprintf(fid,'\n');

% OBR reference times
fprintf(fid,'OBR reference:\n');
fprintf(fid,'\tIndex\tTransit\n');
fprintf(fid,'\t%d\t%.3f\n',transpose(object.OBRreference));
fprintf(fid,'\n');

end