% view View object graphically
%
% This method displays PDV objects as line plots.  The default view is the
% measured signal.
%     >> view(object);
%     >> view(object,'Measurement'); % same as above
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
    mode='measurement';
end
assert(ischar(mode),'ERROR: invalid mode');

% generate plot
% NEEDS WORK!
switch lower(mode)
    case 'measurement'
        h=view(object.Measurement);
    case 'preview'
        h=view(object.Preview,'show');
        h=h.image;
    case 'frequency'
        N=numel(object.Frequency);
        assert(N>0,'ERROR: beat frequency has not been calculated yet');
        color=lines(N);        
        h=nan(N,2);
        %label=cell(1,N);
        figure;
        for n=1:N
            %label{n}=object.Frequency{n}.Name;
            subplot(2,1,1);
            h(n,1)=view(object.Frequency{n},1,gca);
           
            subplot(2,1,2);
            set(h(n,:),'Color',color(n,:));
        end
        ylabel('Beat frequency');
        %legend(label,'Location','best');
    case 'velocity'
        N=numel(object.Velocity);
        assert(N>0,'ERROR: beat frequency has not been calculated yet');
        color=lines(N);
        h=nan(1,N);
        label=cell(1,N);
        for n=1:N
            h(n)=view(object.Velocity{n},1);
            set(h(n),'Color',color(n,:));
            label{n}=object.Velocity{n}.Name;
        end
        ylabel('Beat frequency');
        legend(label,'Location','best');
    otherwise
        error('ERROR: invalid view mode');
end
apply(object.GraphicOptions,h);

% manage output
if nargout>0
    varargout{1}=h;
end

end