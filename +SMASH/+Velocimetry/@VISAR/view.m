% VIEW - Display a VISAR object
% 
% This method plots the various Signal objects and Signal Group objects
% of a VISAR object.  All possible syntaxes are below.
%     >> view(object);
%     >> view(object,Signal); 
%
% There are a variety of Signal options
%     'Measurement'  - View the Raw measurement signals.  This is the
%                      default.
%     'Experiment'   - View the Experimental region of the raw signals.
%     'Reference'    - View the reference region of the raw signals.
%     'Processed'    - View the VISAR signals after scaling, shifting, and
%                      filtering.  The signal must be analyzed for this
%                      option.
%     'Quadrature'   - View the quadrature signals.  The VISAR object must
%                      be analyzed for this option.
%     'Lissajou  '   - View the VISAR Lissajou with the ellipse fit.  The
%                      VISAR object must be analyzed for this option.
%     'Fringeshift'  - View the Fringe Shift signal.  The VISAR object must
%                      be analyzed for this option.
%     'Contrast'     - View the Contrast signal.  The VISAR object must
%                      be analyzed for this option.
%     'Velocity'     - View the Velocity signal.  The VISAR object must
%                      be analyzed for this option.
% 
% created March 10, 2016 by Paul Specht (Sandia National Laboratories)
%
function varargout=view(object,mode,target)

% manage input
if (nargin<2) || isempty(mode)
    mode='measurement';
end
assert(ischar(mode),'ERROR: Invalid View Mode');

if (nargin<3) || isempty(target)
    target=[];
end

% generate plot
n=object.Measurement.NumberSignals;
if n > 3
    label={'D1A','D1B','D2A','D2B'};
elseif n > 2
    label={'D1','D2','BIM'};
else
    label={'D1','D2'};
end
switch lower(mode)
    case 'measurement'
        h=view(object.Measurement,target);
        ylabel('Amplitude');
        xlabel('Time');
        legend(label,'Location','best');
    case 'processed'
        assert(isa(object.Processed,'SMASH.SignalAnalysis.SignalGroup'),...
            'ERROR: Must Analyze Signal to View');
        h=view(object.Processed,target);
        ylabel('Amplitude');
        xlabel('Time');
        legend(label,'Location','best');
    case 'experiment'
        if isa(object.Processed,'SMASH.SignalAnalysis.SignalGroup')
            h=view(object.Processed,target);
        else
            h=view(object.Measurement,target);
        end
        xlim(object.ExperimentalRegion);
        ylabel('Amplitude');
        xlabel('Time');
        legend(label,'Location','best');
    case 'reference'
        assert(length(object.ReferenceRegion)==2,...
            'ERROR: Must Define a Reference Region');
        if isa(object.Processed,'SMASH.SignalAnalysis.SignalGroup')
            h=view(object.Processed,target);
        else
            h=view(object.Measurement,target);
        end
        xlim(object.ReferenceRegion);
        ylabel('Amplitude');
        xlabel('Time');
        legend(label,'Location','best');
    case 'fringeshift'
        assert(isa(object.FringeShift,'SMASH.SignalAnalysis.Signal'),...
            'ERROR: Must Analyze Signal to View');
        h=view(object.FringeShift,target);
        ylabel('Phase');
        xlabel('Time');
    case 'contrast'
        assert(isa(object.Contrast,'SMASH.SignalAnalysis.Signal'),...
            'ERROR: Must Analyze Signal to View');
        h=view(object.Contrast,target);
        ylabel('Amplitude');
        xlabel('Time');
    case 'lissajou'
        assert(isa(object.Quadrature,'SMASH.SignalAnalysis.SignalGroup'),...
            'ERROR: Must Analyze Signal to View');
        target=SMASH.MUI.Figure;
        target=target.Handle;
        target=axes('Parent',target);
        axes(target);
        h=line(object.Quadrature.Data(:,1),object.Quadrature.Data(:,2),'Parent',target);
        apply(object.Quadrature.GraphicOptions,h);
        theta=linspace(0,2*pi,200);
        x=object.EllipseParameters(1)+object.EllipseParameters(3)*cos(theta);
        y=object.EllipseParameters(2)+object.EllipseParameters(4)*sin(theta-object.EllipseParameters(5));
        line(x,y,'Color',[1 0 0],'LineWidth',2);
        ylabel('Amplitude');
        xlabel('Amplitude');
        legend('Lissajou','Elliptical Fit','Location','best');
    case 'quadrature'
        assert(isa(object.Quadrature,'SMASH.SignalAnalysis.SignalGroup'),...
            'ERROR: Must Analyze Signal to View');
        h=view(object.Quadrature,target);
        ylabel('Amplitude');
        xlabel('Time');
        legend('DX','DY','Location','best');
    case 'velocity'
        assert(isa(object.Velocity,'SMASH.SignalAnalysis.Signal'),...
            'ERROR: Must Analyze Signal to View');
        h=view(object.Velocity,target);
        xlabel('Time');
        ylabel('Velocity');
    otherwise
        error('ERROR: Invalid View Mode');
end

% manage output
if nargout>0
    varargout{1}=h;
end   

end