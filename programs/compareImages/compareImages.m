function compareImages()

%% create GUI
fig=SMASH.MUI.Figure('Units','normalized','Position',[0.05 0.05 0.90 0.90],...
    'Visible','off','IntegerHandle','off','Name','Compare images');%,'HandleVisibility','callback');
setappdata(fig.Handle,'ImageLoaded',false([1 2]));

hm=uimenu(fig.Handle,'Label','File');
uimenu(hm,'Label','Load reference','Callback',@loadReference);
uimenu(hm,'Label','Load current','Callback',@loadCurrent);

hm=uimenu(fig.Handle,'Label','Analyze');
uimenu(hm,'Label','Calculate centroids','Callback',@analyzeCentroids);

haxes(1)=axes('Parent',fig.Handle,'Units','normalized','OuterPosition',[0.0 0.0 0.5 1.0]);
haxes(2)=axes('Parent',fig.Handle,'Units','normalized','OuterPosition',[0.5 0.0 0.5 1.0]);
set(haxes,'Box','on');
AxesLink=linkprop(haxes,{'XLim' 'YLim' 'CLim'});
setappdata(fig.Handle,'AxesLink',AxesLink);

himage(1)=imagesc('Parent',haxes(1),'Visible','off');
himage(2)=imagesc('Parent',haxes(2),'Visible','off');

hbar(1)=SMASH.MUI.Colorbar(haxes(1));
hbar(2)=SMASH.MUI.Colorbar(haxes(2));
colormap(fig.Handle,'jet');

figure(fig.Handle);

%% callbacks
    function loadReference(varargin)
        [success,filename]=loadImage('reference',himage(1));
        if success
            axis(haxes(1),'tight');
            loaded=getappdata(fig.Handle,'ImageLoaded');
            loaded(1)=true;
            setappdata(fig.Handle,'ImageLoaded',loaded);
            label={};
            label{1}='Reference image';
            [~,filename,ext]=fileparts(filename);
            label{2}=[filename ext];
            title(haxes(1),label,'Interpreter','none');
        end
    end

    function loadCurrent(varargin)
        [success,filename]=loadImage('current',himage(2));
        if success
            loaded=getappdata(fig.Handle,'ImageLoaded');
            loaded(2)=true;
            setappdata(fig.Handle,'ImageLoaded',loaded);
            label{1}='Current image';
            [~,filename,ext]=fileparts(filename);
            label{2}=[filename ext];
            title(haxes(2),label,'Interpreter','none');
        end
    end

    function analyzeCentroids(varargin)
        loaded=getappdata(fig.Handle,'ImageLoaded');
        if ~all(loaded)
            return
        end
       object=pullROI(himage,'removeBG');
       threshold=0.05;
       xc=nan(2,1);
       yc=nan(2,1);      
       for m=1:2
           x=object{m}.Grid1;
           y=object{m}.Grid2;
           [x,y]=meshgrid(x,y);
           value=threshold*max(object{m}.Data(:));
           keep=object{m}.Data >= value;
           z=object{m}.Data(keep);
           x=x(keep);
           y=y(keep);
           xc(m)=trapz(x,x.*z)/trapz(x,z);
           yc(m)=trapz(y,y.*z)/trapz(y,z);
       end
       dlg=SMASH.MUI.Dialog;
       dlg.Hidden=true;
       dlg.Name='Centroid analysis';
       h=addblock(dlg,'text','Centroid analysis');
       set(h,'FontWeight','bold');
       h=addblock(dlg,'edit','Reference center (x,y):',20);
       set(h(2),'String',sprintf('\t(%#.6g, %#.6g)',xc(1),yc(1)),...
           'Style','text','BackgroundColor',get(dlg.Handle,'Color'));
       h=addblock(dlg,'edit','Current center (x,y):',20);
       set(h(2),'String',sprintf('(%#.6g, %#.6g)',xc(2),yc(2)),...
           'Style','text','BackgroundColor',get(dlg.Handle,'Color'));
       h=addblock(dlg,'edit','Difference (x,y):',20);
       set(h(2),'String',sprintf('(%#.3g, %#.3g)',diff(xc),diff(yc)),...
           'Style','text','BackgroundColor',get(dlg.Handle,'Color'));              
       locate(dlg,'center');
       dlg.Hidden=false;       
    end

end