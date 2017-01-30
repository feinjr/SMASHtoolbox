function object=pullROI(himage,removeBG)

haxes=ancestor(himage(1),'axes');
xb=get(haxes,'XLim');
yb=get(haxes,'YLim');

object=cell(2,1);
for m=1:2
    % create cropped object
    x=get(himage(m),'XData');
    y=get(himage(m),'YData');
    z=get(himage(m),'CData');
    object{m}=SMASH.ImageAnalysis.Image(x,y,z);
    object{m}=crop(object{m},xb,yb);
    %
    if strcmpi(removeBG,'removeBG')
        x=object{m}.Grid1; 
        x=x(:);
        Nx=numel(x);
        y=object{m}.Grid2;
        y=y(:);
        Ny=numel(y);
        xe=[x; repmat(x(end),[Ny 1]); x(end:-1:1); repmat(x(1),[Ny 1])];
        ye=[repmat(y(1),[Nx 1]); y; repmat(y(end),[Nx 1]); y(end:-1:1)];
        ze=lookup(object{m},xe,ye);
        matrix=ones(numel(ze),3);
        matrix(:,2)=xe;
        matrix(:,3)=ye;
        param=matrix \ ze;
        [X,Y]=meshgrid(x,y);
        matrix=ones(numel(X),3);
        matrix(:,2)=X(:);
        matrix(:,3)=Y(:);        
        fit=matrix*param;
        fit=reshape(fit,[Ny Nx]);
        object{m}=object{m}-fit;
    end
     
end

end
