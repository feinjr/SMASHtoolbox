
function object=import(object,data)

% manage multiple imports
if numel(data)>1
    error('ERROR: this class does not support multi-file import');
end

% manage individual imports
switch data.Format
    case 'column'
        data=data.Data;
        if size(data,1)==1
            object.Data=data(:,1);
            object.Grid=transpose(1:size(data,1));
        else
            object.Grid=data(:,1);
            object.Data=data(:,2);
        end             
    case {'agilent','lecroy','tektronix','yokogawa'}
        object.Grid=data.Time;
        object.Data=data.Signal;
    case 'dig'
        object.Grid=data.Time;
        object.Data=data.Signal;        
    case 'pff'
        switch data.PFFdataset
            case 'PFTUF1'
                object.Grid=data.X;
                object.Data=data.Data;
            case 'PFTNF3'
                object.Grid=data.X;
                object.Data=data.Data;
            otherwise
                error('ERROR: cannot import Signal from this PFF dataset');
        end              
    otherwise
        error('ERROR: cannot import Signal from this format');
end

object.PlotOptions=set(object.PlotOptions,...
    'Marker','none','LineStyle','-');

end