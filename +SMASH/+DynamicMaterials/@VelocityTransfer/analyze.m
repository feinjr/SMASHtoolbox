% analyze Perform VelocityTransfer window correction
%
% This method performs the transfer analysis on the VelocityTransfer
% object.
%
%     >> object=analyze(object);
%
% See also VelocityTransfer
%
%
% created March 26, 2015 by Justin Brown (Sandia National Laboratories)
%
function object=analyze(object)

%helpers
npts = object.Settings.NumberPoints;
dt = (object.MeasuredWindow.Grid(end)-object.MeasuredWindow.Grid(1))/length(object.MeasuredWindow.Grid);


% Determine a functional form for time causality correlation
assert(numel(object.Settings.WindowTimes)==numel(object.Settings.InsituTimes),'Time arrays must be the same size');
[windowtimes,ia] = sort(object.Settings.WindowTimes);
insitutimes = object.Settings.InsituTimes(ia);
p=polyfit(object.Settings.WindowTimes,object.Settings.InsituTimes,3);
%windowstep = (max(windowtimes)-min(windowtimes))/(5-1);
%window_start = min(windowtimes);


tresult=[];vresult=[];
tshift=[];tscale=[];
for i=1:length(windowtimes)-1;
    
    %Define time regions
    %window_end = window_start + windowstep;
    window_start = windowtimes(i);
    window_end = windowtimes(i+1);
    %insitu_start = polyval(p,window_start);
    %insitu_end = polyval(p,window_end);
    insitu_start = insitutimes(i);
    insitu_end = insitutimes(i+1);
    
    object.MeasuredWindow=limit(object.MeasuredWindow,[window_start window_end]);
    object.SimulatedWindow=limit(object.SimulatedWindow,[window_start window_end]);
    object.SimulatedInsitu=limit(object.SimulatedInsitu,[insitu_start insitu_end]);
    
    [t{1},v{1}] = limit(object.MeasuredWindow);
    [t{2},v{2}] = limit(object.SimulatedWindow);
    [t{3},v{3}] = limit(object.SimulatedInsitu);
    
    %Put everything on common normalized time base
    tnorm = linspace(0, 1, npts)';
    
    for j=2:3
        tshift(j) = min(t{j}); 
        tscale(j) = max(t{j})-min(t{j});
        nt{j} = (t{j}-tshift(j))./tscale(j);
        %Interpolate to normalized time base
        nv{j} = interp1(nt{j},v{j},tnorm,'pchip');
    end
    nt{1} = (t{1}-tshift(2))./tscale(2);
    nv{1} = interp1(nt{1},v{1},tnorm,'pchip');
    
    
    %FFT Solution
    n_fpts = 2^nextpow2((2*npts-1)*2);
   
    for j=1:3
        vfft{j} = fft(nv{j},n_fpts);
    end
    TF = vfft{3}./vfft{2};
    
    vout = ifft(TF.*vfft{1}); vout = vout(1:npts);
    tout = tnorm.*tscale(3)+tshift(3);
    
    tresult=[tresult;tout];
    vresult=[vresult;vout];
end
   


    %Interpolate back to original timebase
    %object.MeasuredWindow=limit(object.MeasuredWindow,[min(windowtimes) max(windowtimes)]);
    %[tfinal,~] = limit(object.MeasuredWindow);
    %vresult = interp1(tresult,vresult,texp,'pchip', 0); tresult=tfinal

    %Remove overlap
    %trim = tresult<max(windowtimes);
    %tresult=tresult(trim); vresult=vresult(trim);
    [~,ia]=unique(tresult);
    object.Results = SMASH.SignalAnalysis.Signal(tresult(ia),vresult(ia));
    object.Results.GraphicOptions.LineColor=[1.00 0.00 0.50]; %pink

    %Reset limits
    object.MeasuredWindow = limit(object.MeasuredWindow,'all');
    object.SimulatedWindow = limit(object.SimulatedWindow,'all');
    object.SimulatedInsitu=limit(object.SimulatedInsitu,'all');
    
    
end


