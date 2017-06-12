function object=importDigitizer(previous)

% generate objects
N=numel(previous);
address=cell(N,1);
name=cell(N,1);
for n=1:N
    address{n}=previous(n).System.Address;
    name{n}=previous(n).Name;
end
object=SMASH.Instrument.Digitizer(address,name);

% restore settings
for n=1:N
    object(n).Acquisition=previous(n).Acquisition;
    object(n).Trigger=previous(n).Trigger;
    object(n).Channel=previous(n).Channel;
    object(n).RemoteDirectory=previous(n).RemoteDirectory;
end

end