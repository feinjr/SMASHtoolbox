% view View object graphically
%
% This method displays PDV objects as line plots.  The default view is the
% measured signal.
%    view(object);
%    view(object,'signal'); % same as above
% Frequency results can be viewed *after* the analysis method has been used.
%    view(object,'Frequency');
%    view(object,'Amplitude);
% Velocity results can be viewed *after* the convert method has been used.
%    view(object,'Velocity');
%
% Specifying an output returns graphic handles for lines from this method.
%     >> h=view(...);
% 
% See also PDV, analyze, convert, preview
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
        N=numel(object.Frequency);
        assert(N>0,'ERROR: frequency has not been calculated yet.  Use the "analyze" method.');
        SMASH.MUI.Figure;
        axes('Box','on');
        color=lines(N);
        h=nan(N,1);
        label=cell(N,1);
        for n=1:N
            label{n}=object.Frequency{n}.Name;
            h(n)=view(object.Frequency{n},gca);
            set(h(n),'Color',color(n,:));
        end
        ylabel('Frequency');
        xlabel('Time');
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
    case 'uncertainty'
        N=numel(object.Uncertainty);
        if N==0
            assert(~isempty(object.RMSnoise),'ERROR: uncertainty not calculated because RMSnoise is not defined');
            error('ERROR: uncertainty has not been calculated yet.  Use the "analyze" method.');
        end        
        SMASH.MUI.Figure;
        axes('Box','on');
        color=lines(N);
        h=nan(N,1);
        label=cell(N,1);
        for n=1:N
            label{n}=object.Uncertainty{n}.Name;
            h(n)=view(object.Uncertainty{n},gca);
            set(h(n),'Color',color(n,:));
        end
        ylabel('Uncertainty');
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