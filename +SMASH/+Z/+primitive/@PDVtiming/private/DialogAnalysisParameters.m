function DialogAnalysisParameters(~,~,object)

dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='Analysis parameters';

addblock(dlg,'text','Experiment:',30);
addblock(dlg,'text',['   ' object.Experiment],30);

label={...
    'Digitizer scaling:' 'Derivative smoothing (ns)' ...
    'Fiducial range (ns)' 'OBR width (ns):'};
width=max(cellfun(@numel,label));

h=addblock(dlg,'edit',label{1},width);
value=sprintf('%g',object.DigitizerScaling);
set(h(end),'Callback',@readEditDouble,...
    'String',value,'UserData',value);

h=addblock(dlg,'edit',label{2},width);
value=sprintf('%g',object.DerivativeSmoothing);
set(h(end),'Callback',@readEditDouble,...
    'String',value,'UserData',value);

h=addblock(dlg,'edit',label{3},width);
value=sprintf('%g',object.FiducialRange);
set(h(end),'Callback',@readEditDouble,...
    'String',value,'UserData',value);

h=addblock(dlg,'edit',label{4},width);
value=sprintf('%g',object.OBRwidth);
set(h(end),'Callback',@readEditDouble,...
    'String',value,'UserData',value);

h=addblock(dlg,'button',{' Done ' ' Cancel '});
set(h(1),'Callback',@done)
    function done(varargin)
        value=probe(dlg); 
        object.DigitizerScaling=sscanf(value{1},'%g');
        object.DerivativeSmoothing=sscanf(value{2},'%g');
        object.FiducialRange=sscanf(value{3},'%g');
        object.OBRwidth=sscanf(value{4},'%g');
        delete(dlg);
    end
set(h(2),'Callback',@cancel);
    function cancel(varargin)   
        delete(dlg);
    end

locate(dlg,'center',object.DialogHandle);
dlg.Hidden=false;
dlg.Modal=true;
uiwait(dlg.Handle);

end