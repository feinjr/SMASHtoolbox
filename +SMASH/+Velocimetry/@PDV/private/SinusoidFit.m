% under construction

function history=SinusoidFit(object,boundary,varargin)

% manage options
Mtotal=numel(boundary);
Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
options.ElectricalHarmonics=1;
options.OpticalHarmonics=1;
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid option name');
    value=varargin{n+1};
    switch lower(name)
        case 'electricalharmonics'
            assert(isnumeric(value) && all(value==round(value) && all(value>0)),...
                'ERROR: invalid ElectricalHarmonics value')
            option.ElectricalHarmonics=value;
        case 'opticalharmonics'
            assert(isnumeric(value) && all(value==round(value) && all(value>0)),...
                'ERROR: invalid OpticalHarmonics value')
            option.OpticalHarmonics=value;
        otherwise
            error('ERROR: invalid option name');
    end
end

% identify active components


%tmid=(time(end)+time(1))/2;

Nboundary=numel(boundary);
[fA,fB]=deal(nan(Nboundary,1));
active=true(Nboundary,1);
for k=1:Nboundary
    [fA(k),fB(k)]=probe(boundary{k},tmid);
    if isnan(fA(k))
        active(k)=false;
    end
end
M=sum(active);

fA=fA(active);
fB=fB(active);
fmid=(fA+fB)/2;
famp=(fB-fA)/2;

% ROI processing

% setup and call analysis function
TargetFunction= @(t,s) SinusoidFit(t,s,boundary,options);
history=analyze@SMASH.SignalAnalysis.ShortTime(...
    object.Measurement,TargetFunction);


end