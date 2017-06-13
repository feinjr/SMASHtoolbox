function SelectPoints
    hold on
    button=1;
    while button==1
        [xpoint,ypoint,button]=ginput(1);
        if button~=1
            break
        end
        defaultLabel=char(string(xpoint));
        CurrentAxis=gca;
        linep=plot([xpoint xpoint],CurrentAxis.YLim,'--r');
        newLabel = inputdlg('Enter Label','',1,{defaultLabel},'on');       
        if isempty(newLabel)~=1
            h = text(xpoint,ypoint,newLabel,'VerticalAlignment','bottom');
            set(h, 'Rotation', 90);
        else
             delete(linep)
        end       
    end
end