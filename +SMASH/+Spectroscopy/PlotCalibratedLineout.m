function [x,y]=PlotCalibratedLineout(image,TimeCoeff,WavelengthCoeffMatrix,TimeDirection,WavelengthDirection,varargin)
   p=inputParser;
   addRequired(p,'image');
   addRequired(p,'TimeCoeff');
   addRequired(p,'WavelengthCoeffMatrix');
   addRequired(p,'TimeDirection');
   addRequired(p,'WavelengthDirection');
   
   addOptional(p,'AtTime',0,@isnumeric);
   addOptional(p,'Range',0,@isnumeric);
   addOptional(p,'AtWavelength',500,@isnumeric);
   addOptional(p,'Select','X');
   parse(p,image,TimeCoeff,WavelengthCoeffMatrix,TimeDirection,WavelengthDirection,varargin{:});
   figure
   if strcmp(p.UsingDefaults, 'AtTime')==0
       [x,y,Pixel]=CalLineout(image,TimeCoeff,...
           p.Results.AtTime,p.Results.Range,WavelengthDirection);
       x=polyval(WavelengthCoeffMatrix(Pixel,:),x);
       xname='Wavelength (nm)';
       tname=strcat(string(p.Results.AtTime),' ns');
   elseif strcmp(p.UsingDefaults, 'AtWavelength')==0
       WavelengthCoeff=WavelengthCoeffMatrix(round(size(WavelengthCoeffMatrix,1)./2,0),:);
       [x,y]=CalLineout(image,WavelengthCoeff,p.Results.AtWavelength,...
           p.Results.Range,TimeDirection);
       x=polyval(TimeCoeff,x);
       xname='Time (ns)';
       tname=strcat(string(p.Results.AtWavelength),' nm');
   else
       close all
       f=figure;
       ax=axes;
       ScaledImage(f,ax,image);
       title('Select lineout region')
       [ROI,~]=DrawRectangle();
       [x,y]=Lineout(image,ROI(1),ROI(2),ROI(3),ROI(4),p.Results.Select);
       if p.Results.Select==TimeDirection
           if p.Results.Select=='X'
               AvePixel=mean(ROI(1),ROI(2));
               AveTimePixel=mean(ROI(3),ROI(4));
           elseif p.Results.Select=='Y'
               AvePixel=mean(ROI(3),ROI(4));
               AveTimePixel=mean(ROI(1),ROI(2));
           end
           x=polyval(TimeCoeff,x);
           xname='Time (ns)';
           wavelength=polyval(WavelengthCoeffMatrix(AveTimePixel,:),AvePixel);
           tname=strcat(string(wavelength),' nm');
       elseif p.Results.Select==WavelengthDirection
           if p.Results.Select=='X'
               AvePixel=mean(ROI(1),ROI(2));
           elseif p.Results.Select=='Y'
               AvePixel=mean(ROI(3),ROI(4));
           end
           x=polyval(WavelengthCoeffMatrix(AvePixel,:),x);
           xname='Wavelength (ns)';
           time=polyval(TimeCoeff,AvePixel);
           tname=strcat(string(time),' ns');
       end
   end
   plot(x,y,'k');
   xlabel(xname);
   ylabel('Intensity (a.u.)');
   title(tname);
    function [x,y,Pixel]=CalLineout(image,CalCoeff,value,range,direction)
        GetPixelCoeff=CalCoeff;
        GetPixelCoeff(end)=GetPixelCoeff(end)-value;
        RootValues=roots(GetPixelCoeff);
        Pixel=round(RootValues(RootValues>0),0);
        if direction=='X'
            Pixel=Pixel(Pixel>1 & Pixel<size(image,2));
            [x,y]=Lineout(image,Pixel-range,Pixel+range,1,size(image,2),'X');
        elseif direction=='Y'
            Pixel=Pixel(Pixel>1 & Pixel<size(image,1));
            [x,y]=Lineout(image,1,size(image,1),Pixel-range,Pixel+range,'Y');
        end
    end
end