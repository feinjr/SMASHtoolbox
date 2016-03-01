function options=processViewOptions(arg)

% default options
options=struct();

options.CloudMode='points';
options.CloudEllipseSpan=0.90;
options.CloudColor='r';
options.CloudMarker='.';
options.CloudMarkerSize=5;
options.CloudLineStyle='-';

options.ModelColor='k';
options.ModelLineStyle='-';

options.XLabel='x';
options.YLabel='y';

% manage input
if (nargin==0) || isempty(arg)
    return
end
assert(isstruct(arg),'ERROR: invalid ViewOptions setting');

% verify options
name=fieldnames(arg);
for n=1:numel(name)
    assert(isfield(options,name{n}),'ERROR: invalid ViewOptions setting');
    value=arg.(name{n});
    switch name{n}
        case 'CloudMode'
            assert(ischar(value),'ERROR: invalid CloudMode value');
            value=lower(value);
            switch value
                case {'points','ellipses','means'}
                    % valid
                otherwise
                    error('ERROR: invalid CloudMode value');
            end
        case 'CloudEllipseSpan'
            assert(isnumeric(value) && isscalar(value) && (value>0) && (value<1),...
                'ERROR: invalid CloudEllipseSpan value');
        case 'CloudColor'
            assert(SMASH.General.testColor(value),...
                'ERROR: invalid CloudColor value');
        case 'CloudMarker'
            switch value
                case {...
                        '+','o','*','.','x','s','sq','square','d','diamond',...
                        '^','v','>','<','p','pentagram',...
                        'h','hexagram','none'}
                    % valid choce
                otherwise
                    error('ERROR: invalid marker');
            end
        case 'CloudMarkerSize'
            assert(isnumeric(value) && isscalar(value) && (value>0),...
                'ERROR: invalid CloudMarkerSize valeu');
        case 'ModelColor'
            assert(SMASH.General.testColor(value),...
                'ERROR: invalid ModelColor value');
        case 'ModelLineStyle'
            switch value
                case {'-','--',':','-.'}
                    % valid choice
                otherwise
                    error('ERROR: invalid ModelLineStyle value');
            end
        case 'XLabel'
            assert(ischar(value),'ERROR: invalid XLabel value');
        case 'YLabel'
            assert(ischar(value),'ERROR: invalid YLabel value');
    end
    options.(name{n})=value;
end
                             

end