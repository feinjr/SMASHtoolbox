% AxesInset : create an axes inset 
%
% This function creates an axes inset, a small copy of the original axes
% that emphasizes a particular region of interest.  The horizontal and
% vertical limits of the inset and its position (with respect) to the
% original can be specified.
%
% Usage:
% >>[hinset,hrectangle]=AxesInset(haxes,'setting',value,...);
%
% If the original axes handle (haxes) is omitted, the function defaults to
% the current axes (as defined by gca).  The following settings can be
% specified.
%   'xlim'     : horizontal range of the inset
%   'ylim'     : vertical range of the inset
%   'position' : inset position  [x0 y0 Lx Ly] relative to the original
%   'boundary' : mark inset ('on') position on original axes
%
% Example
% figure; line % create a basic axes
% hinset=AxesInset('xlim',[0.1 0.2],'ylim',[0.1 0.2]);

% updated 8/18/2011 by Daniel Dolan
function varargout=AxesInset(varargin)

%%%%%%%%%%%%%%%
% input check %
%%%%%%%%%%%%%%%
if (nargin==0) || ischar(varargin{1})
    haxes=gca;
elseif ishandle(varargin{1})
    haxes=varargin{1};
    varargin=varargin(2:end);
else
    error('ERROR: invalid first input');
end

if rem(numel(varargin),2)~=0
    error('Unmatched pair of input arguments')
end

% default settings
xlimits=xlim(haxes);
ylimits=ylim(haxes);
pos=[0.70 0.05 0.25 0.25];
boundary='on';

% sweep through remaining inputs
for ii=1:2:numel(varargin)
    name=lower(varargin{ii});
    value=varargin{ii+1};
    switch name
        case 'xlim'
            xlimits=value;
        case 'ylim'
            ylimits=value;
        case 'position'
            pos=value;
        case boundary
            boundary=value;
        otherwise
            fprintf('Unrecognized input ''%s'' ingnored',name);
    end
end

if isempty(xlimits)
    error('No xlimits were given!');
end
if isempty(ylimits)
    error('No ylimits were given!');
end

%%%%%%%%%%%%%%%%
% create inset %
%%%%%%%%%%%%%%%%
fig=ancestor(haxes,'figure');
hinset=copyobj(haxes,fig);
set(hinset,'Color','none','XLim',xlimits,'YLim',ylimits,'Box','on')

% position inset
mainpos=get(haxes,'Position');
insetpos(1)=mainpos(1)+pos(1)*mainpos(3);
insetpos(2)=mainpos(2)+pos(2)*mainpos(4);
insetpos(3)=mainpos(3)*pos(3);
insetpos(4)=mainpos(4)*pos(4);
set(hinset,'Position',insetpos);

% delete extraneous labels from inset
delete(get(hinset,'Xlabel'));
delete(get(hinset,'Ylabel'));
delete(get(hinset,'Title'));
ht=findall(hinset,'Type','text');
delete(ht);

% draw inset box on original axes
if strcmpi(boundary,'on')
    boxpos(1)=xlimits(1);
    boxpos(2)=ylimits(1);
    boxpos(3)=diff(xlimits);
    boxpos(4)=diff(ylimits);
    hrectangle=rectangle('Parent',haxes,'Position',boxpos,...
        'LineStyle','--');
else
    hrectangle=[];
end

%%%%%%%%%%%%%%%%%
% handle output %
%%%%%%%%%%%%%%%%%
if nargout>=1
    varargout{1}=hinset;
end

if nargout>=2
    varargout{2}=hrectangle;
end