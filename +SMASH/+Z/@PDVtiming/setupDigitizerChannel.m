% setupDigitizerChannel Set up digitizer channel(s)
%
% This method defines the available digitizer channels in a PDV
% measurement.  Digitizer channels are defined by a set of unique integers
% within a cell array; each element of the cell array describes the channel
% numbers for one digitizer.
%    setupDigitizerChannel(object,index);
% For example, the input:
%    {[1 3] [1 2 3 4]}
% indicates that the first digitizer has two channels (1 and 3) while the
% second digitizer has four channels (1--4).
%
% Each digitizer channel is assigned an internal delay describing
% misalignment with the digitizer's time base.  The default delay values
% are zero for every digitizer channel.   Custom values are specfified as
% follows.
%    setupDigitizerChannel(object,index,delay);
% The input can be a scalar, numeric array, or cell array.
%    -Scalar values are replicated for every digitizer channel.
%    -Numeric arrays are relicated to every digitizer *if* the number of
%    arrays is consistent with the channel index.
%    -Cell arrays must be consistent with the index array.
% NOTE: relative channels delays should be nearly zero for calibrated
% digitizers.  This correction is meant for minute corrections within a
% digitizer, not overall time shifts.
%
% See also PDVtiming, setupDigitizer
%

%
% created December 14, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function setupDigitizerChannel(object,index,delay)

% manage input
assert(nargin>=2,'ERROR: insufficient input');
ND=numel(object.Digitizer);

if isnumeric(index)
    index=repmat({index},[ND 1]);
end
assert(iscell(index),'ERROR: invalid digitizer channel index');
for n=1:ND
    assert(isValidIndex(index{n}),...
        'ERROR: invalid digitizer channel index');
    index{n}=reshape(index{n},[1 numel(index{n})]);
    temp=unique(index{n});
    assert(numel(temp)==numel(index{n}),...
        'ERROR: repeated digitizer channel index');
end

if (nargin<3) || isempty(delay)
    delay=0;
end
if isnumeric(delay)
    temp=cell(ND,1);
    if isscalar(delay)
        for n=1:ND
            temp{n}=repmat(delay,size(index{n}));
        end        
    else
        delay=reshape(delay,[1 numel(delay)]);
        for n=1:ND
            assert(numel(delay)==numel(index{n}),...
                'ERROR: number of index/delay values is not consistent');
            temp{n}=delay;
        end      
    end    
    delay=temp;
end
assert(iscell(delay),'ERROR: invalid digitizer channel delay');
for n=1:ND
    assert(numel(delay{n})==numel(index{n}),...
        'ERROR: number of index/delay values is not consistent');      
end

%store values
object.DigitizerChannel=index;
object.DigitizerChannelDelay=delay;

end