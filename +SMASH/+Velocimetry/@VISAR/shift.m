% SHIFT -Shift the times scales of VISAR Signals
%
% This object determines the relative time shifts between VISAR signals
% using a fiducial in the signal.  The possible sytnaxes are below.
%      >> object=shift(object,method);
%      >> object=shift(object);
%
% There are two methods for determining the location of hte timing
% fiducials in each VISAR signal
%     'manual'  - The fiducial times are slected by the user on a graph of 
%                 the raw signal. This is done sequentially for each 
%                 signal.  This is the default.
%     'maximum' - The maximum value in the field of view of a graph of the
%                 raw signal is used.  The field of view is set after the  
%                 user selects the "Done" button located on the graph. 
%                 Each signal is done sequentially. 
%     'Fit' - *UNDER CONSTRUCTION* 
%
% The timeshifts are not a protected property, so they can also be set in
% the command window
%     >> object.Timeshifts=[t1 t2 t3 t4];
% To shift all signals by a single amount one can manually add that amount
% to the calculated relative shifts
%     >> object.TimeShifts=object.Timeshifts+t
%
% The first time shift is applied to the first signal.  If only one
% timeshift is entered onlyt he first signal is shifted.  If there are more
% timeshifts the signals, the extra timeshifts are ignored.  
%
% Timeshifts do not alter any defined experimental of reference ROIs
%
% created March 15 2016 by Paul Specht (Sandia National Laboratories) 
%
function object=shift(object,method)

%handle inputs
if nargin == 1
    method='manual';
end

N=object.Measurement.NumberSignals;
x=zeros(1,N);
if strcmpi(method,'Manual')
    target=SMASH.MUI.Figure;
    target=target.Handle;
    for k=1:N
        view(object.Measurement,k,target);
        title(gca,'Use Mouse to Select the Limiting Bounds');
        [x(k),~]=ginput(1);
        cla reset
    end
elseif strcmpi(method,'Maximum')
    target=SMASH.MUI.Figure;
    target=target.Handle;
    for k=1:N
        view(object.Measurement,k,target);
        title(gca,'Use zoom/pan to select limit region');
        hc=uicontrol('Parent',gcf,...
            'Style','pushbutton','String',' Done ',...
            'Callback','delete(gcbo)');
        waitfor(hc);
        bound=xlim;
        [~,startloc]=min(abs(object.Measurement.Grid - bound(1)));
        [~,endloc]=min(abs(object.Measurement.Grid - bound(2)));
        [~,loc]=max(object.Measurement.Data(startloc:endloc,k));
        x(k)=object.Measurement.Grid(startloc+loc-1);
        cla reset
        clear hc
    end
else
    error('ERROR: invalid shift method');
end
close(target);

%handle output
x=x(1)-x;
object.TimeShifts=x;

end