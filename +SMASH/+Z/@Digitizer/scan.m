%
% object=scan('*');
% object=scan('0-10');
% 
% object=scan('*.*');

function object=scan(in)

% manage input
assert(ischar(in),'ERROR: invalid scan range');
period=strfind(object,'.');
Nperiod=numel(period);
assert(any(Nperiod==0:3),'ERROR: invalid scan range');

machine=SMASH.Z.Digitizer.localhost();
address=cell(1,4);
for k=1:4
    if Nperiod
end


end