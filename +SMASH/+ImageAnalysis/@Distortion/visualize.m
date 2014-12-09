% VISUALIZE Generate a graphical representation of a Distortion object.
%
% This method displays various graphical representations of distortion.
%
% See also Distortion, apply, blur
%

%
%
%
function varargout=visualize(object,mode,haxes)

% handle input
if (nargin<2) || isempty(mode)
    mode='isomesh';
end

if (nargin<3) || isempty(haxes)
    figure;
    haxes=axes('Box','on');
    newaxes=true;
else
    newaxes=false;
end
axes(haxes);

% generate graphics
switch lower(mode)
    case {'isopoints','points'}
        h=line(object.IsoPoints(:,1),object.IsoPoints(:,2));
        apply(object.GraphicOptions,h);
        if newaxes
            label=sprintf('Isopoints for "%s"',object.Name);
            title(label);
        end
    case 'isomesh'
        x=[];
        y=[];
        for m=1:size(object.IsoMesh1,1)
            x=[x; object.IsoMesh1(m,:)'; NaN]; %#ok<AGROW>
            y=[y; object.IsoMesh2(m,:)'; NaN]; %#ok<AGROW>
        end
        for n=1:size(object.IsoMesh1,2)
            x=[x; object.IsoMesh1(:,n); NaN]; %#ok<AGROW>
            y=[y; object.IsoMesh2(:,n); NaN]; %#ok<AGROW>
        end
        h=line(x,y,'Color',get(object.GraphicOptions,'LineColor'));
        if newaxes
            label=sprintf('Isomesh for "%s"',object.Name);
            title(label);
        end
    case 'arcmesh'
        x=[];
        y=[];
        for m=1:size(object.ArcMesh1,1)
            x=[x; object.ArcMesh1(m,:)'; NaN]; %#ok<AGROW>
            y=[y; object.ArcMesh2(m,:)'; NaN]; %#ok<AGROW>
        end
        for n=1:size(object.ArcMesh1,2)
            x=[x; object.ArcMesh1(:,n); NaN]; %#ok<AGROW>
            y=[y; object.ArcMesh2(:,n); NaN]; %#ok<AGROW>
        end
        h=line(x,y,'Color',get(object.GraphicOptions,'LineColor'));
        if newaxes
            label=sprintf('Arcmesh for "%s"',object.Name);
            title(label);
        end
    case 'vector'
        shift1=object.ArcMesh1-object.IsoMesh1;
        shift2=object.ArcMesh2-object.IsoMesh2;
        previous=get(gca,'NextPlot');
        if ~newaxes
            hold on
        end
        h=quiver(...
            object.IsoMesh1,object.IsoMesh2,shift1,shift2,0,...
            'Color',get(object.GraphicOptions,'LineColor'),...
            'Marker',get(object.GraphicOptions,'Marker'));
        if newaxes
            label=sprintf('Isopoints for "%s"',object.Name);
            title(label);
        end      
        set(gca,'NextPlot',previous);
    otherwise
        if newaxes
            delete(ancestor(haxes,'figure'))
        end
        error('ERROR: invalid visualization mode');        
end

if newaxes
    xlabel(object.Grid1Label);
    ylabel(object.Grid2Label);
    set(haxes,'YDir','reverse');
end

% handle output
if nargout>0
    varargout{1}=h;
end

end