%
% printFigure(filename);
% printFigure(fig,filename);
% printFigure(fig,filename,option,value,...)

function varargout=printFigure(varargin)

% manage input
assert(nargin>=1,'ERROR: insufficient input');

if ishandle(varargin{1})
    type=get(varargin{1},'Type');
    assert(strcmpi(type,'figure'),'ERROR: invalid figure handle');
    fig=varargin{1};
    varargin=varargin(2:end);
else
    fig=gcf;
end

filename=varargin{1};
assert(ischar(filename),'ERROR: invalid file name');
varargin=varargin(2:end);

Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
option=struct('resolution',300,'color','on','quality',100);
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid option name');
    name=lower(name);
    value=varargin{n+1};
    switch name        
        case 'resolution'
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: invalid resolution value');
            if value<50
                warning('SMASH:printFigure',...
                    'Very low figure resolution requested');
            elseif value>1200
                warning('SMASH:printFigure',...
                    'Very high figure resolution requested');
            end
        case 'color'
            assert(ischar(value),'ERROR: invalid color mode');
            value=lower(value);
            assert(strcmp(value,'on') || strcmp(value,'off'),...
                'ERROR: invalid color mode');
        case 'quality'
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: invalid quality value');
            assert((value>1) && (value<=100),...
                'ERROR: invalid quality value');
        otherwise
            error('ERROR: "%s" is an invalid option name');
    end
    option.(name)=value;
end

% print file based on extenstion
set(fig,'PaperPositionMode','auto');

resolution=sprintf('-r%g',option.resolution);

arg={};
[~,~,ext]=fileparts(filename);
switch lower(ext)
    case '.eps'
        switch option.color
            case 'on'
                format='-depsc';
            case 'off'
                format='-deps';
        end   
        arg={fig format  '-loose' resolution filename};
    case {'.jpg' '.jpeg'}        
        format=sprintf('-djpeg%g',option.quality);
    case '.pdf'
        format='-dpdf';
        units=get(fig,'Units');
        paperunits=get(fig,'PaperUnits');
        set(fig,'Units',paperunits);
        pos=get(fig,'Position');
        set(fig,'PaperSize',pos(3:4));
        set(fig,'Units',units);
    case '.png'
        format='-dpng';
    case {'.tif' '.tiff'}
        format='-dtiff';
    otherwise
        assert(strcmp(filename,'-clipboard'),'ERROR: invalid file name');
        arg={fig filename '-dpdf'};
end
if isempty(arg)
    arg={fig format  resolution filename};
end

print(arg{:});

% manage output
if nargout>0
    varargout='arg';
end

end