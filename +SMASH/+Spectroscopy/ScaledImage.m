function ScaledImage(fig,ax,image,varargin)
p=inputParser;
addRequired(p,'fig');
addRequired(p,'ax');
addRequired(p,'image');
addOptional(p,'X',[1 size(image,2)],@isnumeric);
addOptional(p,'Y',[1 size(image,1)],@isnumeric);
parse(p,fig,ax,image,varargin{:});

imagesc(ax,image,'XData',p.Results.X,'YData',p.Results.Y);
colorbar
b = uicontrol('Parent',fig,'Style','slider','Units','normalized','Position',[.96 .12 .03 .8],...
    'value',max(image(:))/2.0, 'min',1, 'max',max(image(:)),'Callback',{@scalefunc});
    function scalefunc(b,~)
        ax.CLim=[0,b.Value];
    end
end