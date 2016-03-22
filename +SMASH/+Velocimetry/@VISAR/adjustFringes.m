% ADJUSTFRINGES - Add or Subtract fringes to the fringe shift record of a
% VISAR object
%
% This method add or subtracts fringes to a VISAR record.  This is done by 
% displaying the velocity record of the VISAR object and the user slecting 
% the times to add or subtract frionges with the mouse.  A Left mouse click
% signifies an added fringe, while a right mouse click signifies a
% subtracted fringe.  When finished adding or subtracting fringes the
% return key should be hit.  The syntax for this method is below.
%     >> object=analyze(object,width);
%
% Width defines the width of the fringe that are added and subtracted.  It
% should be specified in units of time. 
%
% The fringe jumps are not a protected property.  They can be modified in 
% the command window.  The format for a fringe jump is a 3 element array.
%     >>object.Jumps=[+/-1 tf w];
% Here the first entry is a +1 or -1 depending on if the fringe is added or
% subtracted.  the term tf is the time of the added fringe, and w is the
% width.  To add multipel fringe jumps enter a Nx3 matrix,  where each row
% is a fringe jump.
%
% If Finge jumps are added in the command window they will not be applied
% to the Fringe shift signal of the object.  they can be applied after
% manual entry witht eh following command
%     >> object=analyze(object,'update');
%
% This method automatically analyzes the signal with using the new fringe
% shift
%
% Created March 17 by Paul Specht (Sandia National Laboratories)
%
function object=adjustFringes(object,width)

assert(isa(object.Velocity,'SMASH.SignalAnalysis.Signal'),...
    'ERROR: Must Analyze Signal to Adjust Fringes');

%mangage input
if nargin == 1
    width=0;
    more=1;
elseif nargin == 2
    if isnumeric(width)
        if numel(width) == 1;
            more=1;
        else
            error('ERROR: Fringe Width Must be a Scalar');
        end
    else
        if strcmpi(width,'Update')
            more=0;
            J=object.Jumps;
        else
            error('ERROR: Invalid Fringe Width');
        end
    end
end

if more == 1
    %obtain input
    view(object,'Velocity');
    title(gca,'Use Mouse to Select the Limiting Bounds');
    [t,~,button]=ginput;
    fig=gcf;
    close(fig)

    %store the input
    J=object.Jumps;
    for k=1:numel(t);
        if button(k) == 1
            J=[J;1 t(k) width];
        else
            J=[J;-1 t(k) width];
        end
    end
    object.Jumps=J;
end

%adjust the fringeshift
Fshift=zeros(numel(object.Velocity.Grid),1);
for k=1:size(J,1)
    if J(k,1) == 1
        factor=1;
    else
        factor=-1;
    end
    if J(k,3) == 0
        Fshift=Fshift+factor*(object.Velocity.Grid >= J(k,2));
    else
        s=J(k,3)/(2*atanh(4/5));
        Fshift=Fshift+factor*(1+tanh((object.Velocity.Grid-J(k,2))/s))/2;
    end
end
object.FringeShift=object.FringeShift+Fshift;

%recalculate velocity
object=analyze(object);

 