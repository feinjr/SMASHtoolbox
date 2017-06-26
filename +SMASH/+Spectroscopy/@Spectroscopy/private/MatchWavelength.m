function ReturnWavelength=MatchWavelength(x,y,centerWavelength,grating)
    order=grating/150;
    y=y/max(y);

[LampX,LampY,Wavelength]=GetHgNeWavelengths();
[PeakPixel,PeakWavelength,PixelCoeff]=GetPeakPixels();
    LampX=LampX*order;
    CenterPixel=polyval(PixelCoeff(:),centerWavelength);
    PixelRange=[round(CenterPixel-(length(x)/2.0)),round(CenterPixel+(length(x)/2.0))];
    MaxInRange=max(LampY(PixelRange(1):PixelRange(2)));
    LampY=LampY/MaxInRange;
    fig=figure;
    p1=plot(x+PixelRange(1),y,'k');
    hold on
    p2=plot(LampX,LampY,'r');

    LineName={'Hg I ', 'Hg I ', 'Hg I ', 'Hg I ', 'Hg I ', 'Hg I ', 'Hg I ',...
        'Ne I ', 'Ne I ', 'Ne I ', 'Ne I ', 'Ne I ', 'Ne I ', 'Ne I ', 'Ne I ',...
        'Ne I ', 'Ne I ', 'Ne I ', 'Ne I ', 'Ne I ', 'Ne I ', 'Ne I ', 'Ne I ',...
        'Ne I ', 'Ne I ', 'Ne I ', 'Ne I ', 'Ne I ', 'Ne I ', 'Ne I ', 'Ne I ', 'Ne I '};
    StringWave=string(num2cell(PeakWavelength));
    for i=1:length(LineName)
        newLabel=LineName{i};
        newLabel=strcat(newLabel,{' '},char(StringWave(i)),'nm');
        if mod(i,2) == 0
            plot([PeakPixel(i) PeakPixel(i)],[-.2,0],'LineStyle','--','Color', [.7 .7 .7]);
            h = text(PeakPixel(i),-.15,newLabel,'VerticalAlignment','bottom','FontSize',7);
        else
            plot([PeakPixel(i) PeakPixel(i)],[0,1],'LineStyle','--','Color', [.7 .7 .7]);
            h = text(PeakPixel(i),1,newLabel,'VerticalAlignment','bottom','FontSize',7);
        end
        set(h, 'Rotation', 90);
    end
    
    ax=gca;
    b = uicontrol('Parent',fig,'Style','slider','Units','normalized','Position',[ax.Position(1) 0 ax.Position(3) .03],...
        'value',x(1)+PixelRange(1), 'min',1, 'max',LampX(end)-x(end),'Callback',{@MovePlot},'SliderStep',[.0001 .01]);
     function MovePlot(b,~)
         delete(p1);
         delete(p2);
        PixelRange=round([b.Value,(b.Value)+x(end)]);
        NewPosition=x+PixelRange(1);
        
        PeakPixelRange=PeakPixel(PeakPixel>NewPosition(1) & PeakPixel<NewPosition(end));
        c = ismember(PeakPixel, PeakPixelRange);
        index=find(c);
        ReturnWavelength=PeakWavelength(index);
        
        MaxInRange=max(LampY(round(PixelRange(1)/order:PixelRange(2)/order)));
        if MaxInRange>=min(LampY(round(PeakPixel/order)) )
            LampY=LampY/MaxInRange;
        end
        
        p1=plot(NewPosition,y,'k');
        p2=plot(LampX,LampY,'r');
        
     end         
 uiwait

end

    
