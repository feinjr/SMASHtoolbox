% analyze Perform timing analysis
%
% This method performs timing analysis for the defined measurement
% connections.  When called without output:
%    analyze(object);
% timing corrections are printed in the command window.  Results may also
% be passed to outputs, suppresing the printed display.
%    [correction,connection,label]=analyze(object);
%
% See also PDVtiming
%

%
% created December 14, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=analyze(object)

% analyze connections
N=size(object.MeasurementConnection,1);
correction=zeros(1,N);
for k=1:N
    % digitizer analysis
    digitizer=object.MeasurementConnection(k,3);
    m=find(object.Digitizer==digitizer);
    channel=object.MeasurementConnection(k,4);
    n=find(object.DigitizerChannel{m}==channel);
    trigger=object.DigitizerTrigger(m);
    SystemDelay=object.DigitizerDelay(m);
    ChannelDelay=object.DigitizerChannelDelay{m}(n);
    correction(k)=trigger-SystemDelay-ChannelDelay;
    % probe analysis
    probe=object.MeasurementConnection(n,1);
    m=find(object.Probe==probe);
    delay=object.ProbeDelay(m); %#ok<FNDSB>
    correction(k)=correction(k)-delay;
    % diagnostic analysis
    diagnostic=object.MeasurementConnection(n,2);
    m=find(object.Diagnostic==diagnostic);
    delay=object.DiagnosticDelay(m); %#ok<FNDSB>
    correction(k)=correction(k)-delay;        
end

% manage output
if nargout==0
    fprintf('%10s  %10s  %10s  %10s  %10s  %-20s\n',...
        'Probe','Diagnostic','Digitizer','Channel','Correction','Measurement');
    %fprintf('\tProbe\tDiagnostic\tDigitizer\tChannel\tCorrection\tLabel\n');   
    N=numel(correction);
    for n=1:N
        fprintf('%10d  %10d  %10d  %10d  ',object.MeasurementConnection(n,:));
        fprintf('%10.3f  ',correction(n));
        fprintf('%-20s\n',object.MeasurementLabel{n});
    end    
else
    varargout{1}=correction;
    varargout{2}=object.MeasurementConnection;
    varargout{3}=object.MeasurementLabel;
end

end