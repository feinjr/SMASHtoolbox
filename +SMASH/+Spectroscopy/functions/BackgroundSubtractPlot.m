
function [Type,InterpolatedBackground,ReturnPoints]=BackgroundSubtractPlot(x,y)
    
        fh = figure('Position', [100, 100, 800, 1000]);
        BaselineTxt = uicontrol(fh,'Style','text','String','Baseline:','Units','normalized','Position',[.34,.97,.1,.02]);
        instructions = uicontrol(fh,'Style','text',....
            'String','Select background subtraction method',...
            'Units','normalized','Position',[0,.93,.73,.03], 'FontSize',12);
        BackgroundDropdown=uicontrol(fh,'Style','popupmenu','String',{'','Flat','PolyFit','MedianFit'},'Callback',{@BackgroundFit}, 'Units','normalized','Position', [0.42, .97, 0.1, .02]);
        InterpolatedBackground=[];
        ReturnPoints=[];
        Type=[];
        LineoutPlot=subplot(2,1,1);
        BackgroundPlot=subplot(2,1,2);

        plot(LineoutPlot,x,y,'k')
        uiwait

    function BackgroundFit(BackgroundDropdown,~)
        if ishandle (fh) == false
            return
        end
        pause(.2);
        InterpolatedBackground=0;
        cla(LineoutPlot)
        cla(BackgroundPlot)
        plot(LineoutPlot,x,y,'k')
        result=BackgroundDropdown.String(BackgroundDropdown.Value);
        Type=result;
        if strcmp('Flat',result)==1
            instructions.String='Click on a representative point in order to subtract a flat background';
            [pointx,pointy] = ginput(1);
            hold on
            scatter(pointx,pointy,7,'r','filled')
            hold on
            InterpolatedBackground=BackgroundSubtract(x,y,'Flat',pointy);
            ReturnPoints=pointy;
        elseif strcmp('PolyFit',result)==1
            instructions.String='Click representative points for a polynomial fit. Right click to end.';
            button=1;
            xpoints=[];
            ypoints=[];
            index=[];
            while sum(button) <=1   % read ginputs until a mouse right-button occurs
                [pointx,pointy,button] = ginput(1);
                hold on
                if button==1
                    scatter(pointx,pointy,7,'r','filled')
                    xpoints(end+1)=pointx; %#ok<AGROW>
                    ypoints(end+1)=pointy; %#ok<AGROW>
                    [~,ind]=min(abs(x-pointx));
                    index(end+1)=ind; %#ok<AGROW>
                end
            end
            xpoints=xpoints(:);
            ypoints=ypoints(:);
            index=index(:);
            prompt={'Enter order of the fit'};
            order = inputdlg(prompt);
            order=(str2double(order));
            InterpolatedBackground=BackgroundSubtract(x,y,'Polynomial',[xpoints,ypoints],'Order',order);            
            ReturnPoints=[xpoints,ypoints,index];
            
        elseif strcmp('MedianFit',result)==1
            instructions.String='Enter the order of the median fit';
            prompt={'Enter order of the fit (>100 is likely'};
            order = inputdlg(prompt);
            order=(str2double(order));
            set(fh, 'currentaxes', LineoutPlot);
            hold on
            InterpolatedBackground=BackgroundSubtract(x,y,'MedianFilter',order);
            ReturnPoints=order;
        end
        
        plot(LineoutPlot,x,InterpolatedBackground,'r');
        newy=y-InterpolatedBackground;
        newy(newy<0)=0; 
        plot(BackgroundPlot,x,newy,'k');
    end

end