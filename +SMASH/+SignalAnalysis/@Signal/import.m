
function object=import(object,data)

object.Name='Signal object';
object.GraphicOptions=SMASH.General.GraphicOptions;
set(object.GraphicOptions,'Marker','none','LineStyle','-');

% manage multiple imports
if numel(data)>1
    error('ERROR: this class does not support multi-file import');
end

% manage individual imports
switch data.Format
    case 'column'
        data=data.Data;
        if size(data,2)==1
            object.Data=data(:,1);
            object.Grid=transpose(1:size(data,1));
        else
            object.Grid=data(:,1);
            object.Data=data(:,2);
        end             
    case {'agilent','keysight','lecroy','tektronix','yokogawa'}
        object.Grid=data.Time;
        object.Data=data.Signal;
    case 'dig'
        object.Grid=data.Time;
        object.Data=data.Signal;
    case 'pff'
        errmsg{1}='ERROR: cannot import this dataset as a Signal object';
        if numel(dataset)>1
            errmsg{2}='     Multiple blocks detected';
            error('%s\n',errmsg{:});
        end
        switch data.PFFdataset
            case {'PFTUF3','PFTUF1','PFTNF3','PFTNG3','PFTNI3'}
                object.Grid=data.X;
                object.Data=data.Data;
                if numel(object.Grid) ~= numel(object.Data)
                    errmsg{2}='     Data is not one-dimensional';
                    error('%s\n',errmsg{:});
                end
            case 'PFTNGD'
                if (numel(data.X)>1) || (numel(data.Data)>1)
                    errmsg{2}='     Data is not one-dimensional';
                    error('%s\n',errmsg{:});
                end
                object.Grid=data.X{1};
                object.Data=data.Data{1};
            otherwise
                errmsg{2}='     Unsupported dataset type';
                error('%s\n',errmsg{:});
        end
    otherwise
        error('ERROR: cannot import Signal from this format');
end

end