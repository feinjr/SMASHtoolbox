% view View object graphically
%
% This method displays PDV objects as line plots.  The default view is the
% measured signal.
%    view(object);
%    view(object,'Signal'); % same as above
% The preview image can also be viewed.
%    view(object,'Preview');
% Results can be viewed *after* the analysis method has been used.
%    view(object,'Amplitude);
%    view(object,'Frequency');
%    view(object,'Velocity');
% Frequency and velocity are shown as single plot if noise amplitude is
% unspecified.  When noise amplitude has been specified or determined by
% the characterize method, view shows the calculated result (frequency or
% velocity) along with the estimated uncertainty.
%
% Specifying an output returns graphic handles for lines from this method.
%     >> h=view(...);
%
% See also PDV, analyze, preview
%

%
% created March 2, 2015 by Daniel Dolan (Sandia National Laboratories)
% revised March 14, 2017 by Daniel Dolan
%    -Added Amplitude view and revised documentation
function varargout=view(object,mode)

% manage input
if (nargin<2) || isempty(mode)
    mode='signal';
end
assert(ischar(mode),'ERROR: invalid mode');

% generate plot
switch lower(mode)
    case 'signal'
        SMASH.MUI.Figure;
        h=view(object.STFT,gca);
    case 'preview'
        SMASH.MUI.Figure;
        h=view(object.Preview,'show',gca);
        h=h.image;
    case 'frequency'
        assert(object.Analyzed,...
            'ERROR: frequency has not been calculated yet.  Use the "analyze" method.');
        N=numel(object.Frequency);
        color=lines(N);
        h=nan(N,1);
        label=cell(N,1);
        SMASH.MUI.Figure;
        for n=1:N
            label{n}=object.Frequency{n}.Name;
            if object.NoiseDefined
                subplot(2,1,1);
                h1=view(object.Frequency{n},gca);
                ylabel('Frequency');
                subplot(2,1,2);
                h2=view(object.FrequencyUncertainty{n},gca);
                ylabel('Uncertainty');
                set([h1 h2],'Color',color(n,:));
                h(n)=h1;
                xlabel('Time');
            else
                h(n)=view(object.Frequency{n},gca);
                set(h(n),'Color',color(n,:));
                xlabel('Time');
                ylabel('Frequency');
            end
        end
        ha=findobj(gcf,'Type','axes');
        set(ha,'Box','on');
        legend(h,label,'Location','best');
    case 'velocity'
        assert(object.Analyzed,...
            'ERROR: frequency has not been calculated yet.  Use the "analyze" method.');
        N=numel(object.Velocity);
        color=lines(N);
        h=nan(N,1);
        label=cell(N,1);
        SMASH.MUI.Figure;
        for n=1:N
            label{n}=object.Velocity{n}.Name;
            if object.NoiseDefined
                subplot(2,1,1);
                h1=view(object.Velocity{n},gca);
                ylabel('Velocity');
                subplot(2,1,2);
                h2=view(object.VelocityUncertainty{n},gca);
                ylabel('Uncertainty');
                set([h1 h2],'Color',color(n,:));
                h(n)=h1;
                xlabel('Time');
            else
                h(n)=view(object.Velocity{n},gca);
                set(h(n),'Color',color(n,:));
                xlabel('Time');
                ylabel('Velocity');
            end
        end
        ha=findobj(gcf,'Type','axes');
        set(ha,'Box','on');
        legend(h,label,'Location','best');
    case 'amplitude'
        N=numel(object.Amplitude);
        assert(N>0,'ERROR: amplitude has not been calculated yet.  Use the "analyze" method.');
        SMASH.MUI.Figure;
        axes('Box','on');
        color=lines(N);
        h=nan(N,1);
        label=cell(N,1);
        for n=1:N
            label{n}=object.Amplitude{n}.Name;
            h(n)=view(object.Amplitude{n},gca);
            set(h(n),'Color',color(n,:));
        end
        ylabel('Signal amplitude');
        xlabel('Time');
        legend(h,label,'Location','best');        
    otherwise
        error('ERROR: invalid view mode');
end

% manage output
if nargout>0
    varargout{1}=h;
end

end