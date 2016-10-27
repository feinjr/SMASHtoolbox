% VIEW - Display a property of VISAR objects
%
% This method plots the various Signal objects and Signal Group objects
% of the specified VISAR objects.  The syntax is below
%     >> view(object1,object2,...,objectN,'Signal',string,'PlotMethod',string,'Target',handle);
%
% There are several Signal options:
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
% There are two PlotMethods:
%      'Sub'         - Plots the object signals in its own axis as a
%                      subplot of the figure.  This is the default for
%                      multiple VISAR objects.
%      'Single'      - Plots all the object signals on a signal axis.  This
%                      is the default for a single VISAR object.
%
% Target is used to specify an axis handle for plotting onto an exisitng 
% figure. This option is only avaible for the 'Single' PlotMethod.  If no
% target is specified a new figure is generated.
%
% created March 10, 2016 by Paul Specht (Sandia National Laboratories)
%
function varargout=view(varargin)

% manage the input
mode='measurement';
target=[];
if nargin < 2
    method='single';
else
    method='sub';
end

counter=1;
while counter <= nargin
    if isa(varargin{counter},'SMASH.Velocimetry.VISAR');
        objs(counter)=counter;
        counter=counter+1;
    elseif ischar(varargin{counter})
        switch lower(varargin{counter})
            case 'signal'
                if counter+1 <= nargin
                    mode=varargin{counter+1};
                    assert(ischar(mode),'ERROR: Invalid Signal');
                else
                    error('ERROR: No Signal Specified');
                end
            case 'plotmethod'
                if counter+1 <= nargin
                    method=varargin{counter+1};
                    assert(ischar(method),'ERROR: Invalid PlotMethod');
                else
                    error('ERROR: No PlotMethod Specified');
                end
            case 'target'
                if counter+1 <= nargin
                    target=varargin{counter+1}(1);
                    method='single';
                    assert(isgraphics(target),'ERROR: Invalid target');
                else
                    error('ERROR: No Target Specified');
                end
            otherwise
                error('ERROR: Invalid Input Designation');
        end
        counter=counter+2;
    else
        error('ERROR: Invalid Input Designation');
    end
end

if isempty(objs)
    error('ERROR: No VISAR object defined');
elseif length(objs) == 1
    method='single';
end

switch lower(method)
    case 'single'
        fig=SMASH.MUI.Figure;
        fig.Hidden=true;
        hand=fig.Handle;
        target(1:length(objs))=axes('Parent',hand);
    case 'sub'
        dim=ceil(sqrt(length(objs)));
        if dim*dim-length(objs) >= dim
            adjust=1;
        else
            adjust=0;
        end
        fig=SMASH.MUI.Figure;
        fig.Hidden=true;
        for m=1:length(objs)
            target(m)=subplot(dim,dim-adjust,m);
        end
    otherwise
        error('ERROR: Invalid PlotMethod');
end

%plot out the signals
label={};
color=lines(4*length(objs));
for k=1:length(objs)
    object=varargin{objs(k)};
    switch lower(mode)
        case 'measurement'
            h=view(object.Measurement,[],target(k));
            type=1;
            label=getLabel(object,label,type);
            setColor(h,color,type,k);             
        case 'processed'
            assert(isa(object.Processed,'SMASH.SignalAnalysis.SignalGroup'),...
                'ERROR: Must Process Signal to View');
            h=view(object.Processed,[],target(k));
            type=1;
            label=getLabel(object,label,type);
            setColor(h,color,type,k);
        case 'experiment'
            if isa(object.Processed,'SMASH.SignalAnalysis.SignalGroup')
                tempobj=crop(object.Processed,object.ExperimentalRegion);
            else
                tempobj=crop(object.Measurement,object.ExperimentalRegion);
            end
            h=view(tempobj,[],target(k));
            type=-1;
            label=getLabel(object,label,1);
            setColor(h,color,type,k);
        case 'reference'
            assert(length(object.ReferenceRegion)==2,...
                'ERROR: Must Define a Reference Region');
            if isa(object.Processed,'SMASH.SignalAnalysis.SignalGroup')
                tempobj=crop(object.Processed,object.ReferenceRegion);
            else
                tempobj=crop(object.Measurement,object.ReferenceRegion);
            end
            h=view(tempobj,[],target(k));
            type=-1;
            label=getLabel(object,label,1);
            setColor(h,color,type,k);
        case 'fringeshift'
            assert(isa(object.FringeShift,'SMASH.SignalAnalysis.Signal'),...
                'ERROR: Must Process Signal to View');
            h=view(object.FringeShift,target(k));
            type=4;
            label=getLabel(object,label,type);
            setColor(h,color,type,k);
        case 'contrast'
            assert(isa(object.Contrast,'SMASH.SignalAnalysis.Signal'),...
                'ERROR: Must Process Signal to View');
            h=view(object.Contrast,target(k));
            type=5;
            label=getLabel(object,label,type);
            setColor(h,color,type,k);
        case 'lissajou'
            assert(isa(object.Quadrature,'SMASH.SignalAnalysis.SignalGroup'),...
                'ERROR: Must Process Signal to View');
            h=line(object.Quadrature.Data(:,1),object.Quadrature.Data(:,2),'Parent',target(k));
            apply(object.Quadrature.GraphicOptions,h);
            type=2;
            label=getLabel(object,label,type);
            setColor(h,color,type,k);
        case 'quadrature'
            assert(isa(object.Quadrature,'SMASH.SignalAnalysis.SignalGroup'),...
                'ERROR: Must Process Signal to View');
            h=view(object.Quadrature,[],target(k));
            type=3;
            label=getLabel(object,label,type);
            setColor(h,color,type,k);
        case 'velocity'
            assert(isa(object.Velocity,'SMASH.SignalAnalysis.Signal'),...
                'ERROR: Must Analyze Signal to View');
            h=view(object.Velocity,target(k));
            type=6;
            label=getLabel(object,label,type);
            setColor(h,color,type,k);
        otherwise
            error('ERROR: Invalid View Mode');
    end
    if type < 2
        ylabel('Amplitude');
        xlabel('Time');
        if length(unique(target)) > 1
            NN=object.Measurement.NumberSignals;
            legend(label{NN*(k-1)+1:NN*k},'Location','best');
        end
    elseif type == 2
        theta=linspace(0,2*pi,200);
        x=object.EllipseParameters(1)+object.EllipseParameters(3)*cos(theta);
        y=object.EllipseParameters(2)+object.EllipseParameters(4)*sin(theta-object.EllipseParameters(5));
        ylabel('Amplitude');
        xlabel('Amplitude');
        if length(unique(target)) > 1
            axes(target(k));
            line(x,y,'Color',[0 0 0],'LineWidth',2);
            labeltemp={label{k},'Elliptical Fit'};
            legend(labeltemp,'Location','best');
        end
    elseif type == 3
        ylabel('Amplitude');
        xlabel('Time');
        if length(unique(target)) > 1
            legend(label{2*(k-1)+1:2*k},'Location','best');
        end
    elseif type == 4
        ylabel('Phase');
        xlabel('Time');
        if length(unique(target)) > 1
            legend(label{k},'Location','best');
        end
    elseif type == 5
        ylabel('Amplitude');
        xlabel('Time');
        if length(unique(target)) > 1
            legend(label{k},'Location','best');
        end
    elseif type == 6
        xlabel('Time');
        ylabel('Velocity');
        if length(unique(target)) > 1
            legend(label{k},'Location','best');
        end
    end
end
if length(unique(target)) == 1
    if type == 2
        line(x,y,'Color',[0 0 0],'LineWidth',2);
        labeltemp=[label,'Elliptical Fit'];
        legend(labeltemp,'Location','best');
    else
        legend(label,'Location','best');
    end
end


fig.Hidden=false;

% manage output
if nargout>0
    varargout{1}=h;
end

    function Label=getLabel(object,label,type)
        if type < 2
            %determine the number of signals
            N=object.Measurement.NumberSignals;
            if N > 3
                l={['D1A-',object.Label],['D1B-',object.Label],['D2A-',object.Label],['D2B-',object.Label]};
            elseif N > 2
                l={['D1-',object.Label],['D2-',object.Label],['BIM-',object.Label]};
            else
                l={['D1-',object.Label],['D2-',object.Label]};
            end
        elseif type == 2
            l={['Lissajou-',object.Label]};
        elseif type == 3
            l={['DX-',object.Label],['DY-',object.Label]};
        elseif type > 3
            l={object.Label};
        end
        Label=[label,l];
    end

    function setColor(handle,Colors,type,k)
        if type < 2
            int=4;
        elseif type == 3
            int=2;
        else
            int=1;
        end
        for n=1:length(handle)
            set(handle(n),'Color',Colors(n+int*(k-1),:));
        end
    end

end