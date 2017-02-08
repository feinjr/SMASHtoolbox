% view View object graphically
%
% This method displays PDV objects as line plots.  The default view is the
% measured signal.
%     >> view(object);
%     >> view(object,'signal'); % same as above
% Results can be viewed *after* the analysis method has been used.
%     >> view(object,'Velocity');
%     >> view(object,'Frequency');
%
% Specifying an output returns graphic handles for lines from this method.
%     >> h=view(...);
% 
% See also PDV, analyze, preview
%

% 
% created March 2, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object,mode)

% manage input
if (nargin<2) || isempty(mode)
    mode='signal';
end
assert(ischar(mode),'ERROR: invalid mode');

% generate plot
SMASH.MUI.Figure;
switch lower(mode)
    case 'signal'
        h=view(object.STFT,gca);
        apply(object.GraphicOptions,h);
    case 'preview'
        h=view(object.Preview,'show',gca);
        h=h.image;
        apply(object.GraphicOptions,h);
    case 'frequency'
        N=numel(object.Frequency);
        assert(N>0,'ERROR: beat frequency has not been calculated yet');
        color=lines(N);        
        h=nan(N,2);
        label=cell(1,N);
        for n=1:N
            label{n}=object.Frequency{n}.Name;
            ha(1)=subplot(2,1,1);
            h(n,1)=view(object.Frequency{n},1,gca);           
            ha(2)=subplot(2,1,2);
            h(n,2)=view(object.Frequency{n},2,gca);
            set(h(n,:),'Color',color(n,:));
        end
        apply(object.GraphicOptions,h);
        ylabel(ha(1),'Beat frequency');
        xlabel(ha(2),'Time');
        ylabel(ha(2),'Uncertainty');
        legend(h(:,1),label,'Location','best');
        title(ha(2),'');
        warning off; %#ok<WNOFF>
        linkaxes(ha,'x');
        warning on; %#ok<WNON>
    case 'velocity'
        N=numel(object.Velocity);
        assert(N>0,'ERROR: beat frequency has not been calculated yet');
        color=lines(N);        
        h=nan(N,2);
        label=cell(1,N);
        for n=1:N
            label{n}=object.Velocity{n}.Name;
            ha(1)=subplot(2,1,1);
            h(n,1)=view(object.Velocity{n},1,gca);           
            ha(2)=subplot(2,1,2);
            h(n,2)=view(object.Velocity{n},2,gca);
            set(h(n,:),'Color',color(n,:));
        end
        apply(object.GraphicOptions,h);
        ylabel(ha(1),'Velocity');
        xlabel(ha(2),'Time');
        ylabel(ha(2),'Uncertainty');
        legend(h(:,1),label,'Location','best');
        warning off; %#ok<WNOFF>
        title(ha(2),'');        
        linkaxes(ha,'x');
        warning on; %#ok<WNON>
    otherwise
        error('ERROR: invalid view mode');
end

% manage output
if nargout>0
    varargout{1}=h;
end

end