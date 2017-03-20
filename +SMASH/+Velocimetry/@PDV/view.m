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
            'ERROR: frequency not available until after the "analyze" method.');
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
        haxes=findobj(gcf,'Type','axes');
        set(haxes,'Box','on');
        if numel(haxes > 1)
            linkaxes(haxes,'x');
        end
        legend(h,label,'Location','best');
    case 'velocity'
        assert(object.Analyzed,...
            'ERROR: velocity not available until after the "analyze" method.');
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
        haxes=findobj(gcf,'Type','axes');
        set(haxes,'Box','on');
        if numel(haxes > 1)
            linkaxes(haxes,'x');
        end
        legend(h,label,'Location','best');
    case 'amplitude'
        N=numel(object.Amplitude);
        assert(N>0,'ERROR: amplitude not available until after the "analyze" method.');
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
        haxes=gca;
    case 'results'
        SMASH.MUI.Figure;
        newfig=gcf;
        try
            [~,hA]=view(object,'Amplitude');
            [~,hF]=view(object,'Frequency');
            [~,hV]=view(object,'Velocity');
        catch
            delete(newfig);
            error('ERROR: results not available until after the "analyze" method.');
        end
        old=ancestor([hA; hF(1); hV(1);],'figure');
        if numel(hF)==1
            height=1/2;
        elseif numel(hF)==2
            height=1/3;
        end        
        new=copyobj(hA,newfig);
        y=1-height;
        set(new,'Units','normalized','OuterPosition',[0.25 y 0.50 height]);
        new=copyobj(hF,newfig);
        for n=1:numel(new)
            y=y-height;
            set(new(n),'Units','normalized','OuterPosition',[0 y 0.50 height]);
        end
        new=copyobj(hV,newfig);
        y=1-height;
        for n=1:numel(new)
            y=y-height;
            set(new(n),'Units','normalized','OuterPosition',[0.50 y 0.50 height]);
        end        
        ha=findobj(newfig,'Type','axes');
        linkaxes(ha,'x');
        for n=1:numel(old)
            delete(old{n})
        end
    otherwise
        error('ERROR: invalid view mode');
end

% manage output
if nargout>0
    varargout{1}=h;
    varargout{2}=haxes(end:-1:1);
end

end