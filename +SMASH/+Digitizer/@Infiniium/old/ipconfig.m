% ipconfig Determine IP configuration
%
% This method determines the IP configuration of the local machine.
%    report=ipconfig();
% The output "report" is a structure with fields 'Address' and 'Subnet'.
% If no output is requested, the configuration report is printed in the
% command window.
%
% See also SMASH.Instrument, ping
%

%
% created April 20, 2017 by Daniel Dolan (Sandia National Laboratories
%   
function varargout=ipconfig()

report=struct('Address','','Subnet','');

[~,result]=system('ipconfig');
stop=strfind(result,sprintf('\n'));
start=1;
for k=1:numel(stop)
    local=result(start:stop(k));
    separator=strfind(local,':');
    if isempty(separator)
        % do nothing
    elseif isscalar(separator)
        name=local(1:separator-1);
        value=local(separator+1:end);
        value=strtrim(value);
        if strfind(name,'Address')
            report.Address=value;
        elseif strfind(name,'Subnet')
            report.Subnet=value;
        end
    else
        error('ERROR : too many colons on one line');
    end
    start=stop(k)+1;
end

if nargout==0
    disp(result);
else
    varargout{1}=report;
end

end