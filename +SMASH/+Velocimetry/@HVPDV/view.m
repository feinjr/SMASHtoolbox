%

function varargout=view(object,mode,varargin)

% manage input
if (nargin<2) || isempty(mode)
    mode='measurement';
end
assert(ischar(mode),'ERROR: invalid view mode');

% generate view
varargout=cell(1,nargout);

switch lower(mode)
    case 'measurement'
       [varargout{:}]=view(object.Measurement,varargin{:}); 
    case 'pulse'
        assert(nargin >= 3,'ERROR: insufficient input');
        if isnumeric(varargin{1})
            pulse=varargin{1};
        elseif strcmpi(varargin{1},'all')
            pulse=1:object.NumberPulses;
        else
            error('ERROR: invalid pulse request');
        end
        N=numel(pulse);
        color=lines(N);
        figure;
        box on;
        for n=1:N
            try
                local=extract(object,pulse(n));
            catch
                error('ERROR: invalid pulse request');
            end
            local.GraphicOptions.LineColor=color(n,:);
            view(local,gca);
        end
end  


end