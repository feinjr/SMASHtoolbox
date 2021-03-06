function object=import(object,data)

object.Name='ImageGroup object';
object.GraphicOptions=SMASH.General.GraphicOptions;
object.GraphicOptions.Title='ImageGroup object';
object.GraphicOptions.YDir='reverse';

% multiple files
if numel(data)>1   
    for k=1:numel(data)
        if k==1
            object=import(object,data(k));
        else
            temp=import(object,data(k));
            object=SMASH.ImageAnalysis.ImageGroup(object,temp);
        end
    end
    object.NumberImages=numel(data);
    return
end

% single file
object.NumberImages=1;
object.Legend={'Image Object'};
switch data.Format
    case 'column'
        object.Data=data.Data;
        assert(ismatrix(object.Data) || ndims(object.Data)==3,...
            'ERROR: cannot import Image from this file');
        object.Grid1=1:size(object.Data,1);
        object.Grid2=transpose(1:size(object.Data,2));
    case {'graphics','winspec','optronis','hamamatsu','film','plate','sydor'}
        object.Grid1=data.Grid1;
        object.Grid2=data.Grid2;
        object.Data=data.Data;
        object.GraphicOptions.ColorMap=data.ColorMap;
    case 'pff'
        errmsg{1}='ERROR: cannot import this dataset into a Signal object';
        switch data.PFFdataset
            case {'PFTUF3','PFTNF3','PFTNG3','PFTNI3'}                        
                object.Grid1=data.X;
                object.Grid2=data.Y;
                object.Data=data.Data;
            case 'PFTNGD'
                if (numel(data.X) < 2)
                    errmsg{2}='     Grid is not two-dimensional';
                    error('%s\n',errmsg{:});               
                end
                object.Grid1=data.X{1};
                object.Grid2=data.X{2};
                if (numel(data.Data) ~= 1)
                    errmsg{2}='     Data is not one-dimensional';
                    error('%s\n',errmsg{:});
                end
                object.Data=data.Data{1};                                               
            otherwise
                error('ERROR: cannot import Image from this PFF dataset');
        end
    otherwise
        error('ERROR: cannot import Image from this format');
end

% check for full color
if ndims(object.Data)==3
    % Query whether to convert to grayscale
    colorStyle=questdlg('Choose slice coordinate','Slice coordinate',...
        ' Grayscale ',' Full color ',' cancel ',' Grayscale ');
    colorStyle=strtrim(colorStyle);
    if strcmp(colorStyle,'cancel')
        return
    end
    
    switch colorStyle
        case 'Grayscale'
            % force scalar data with correct numerical format
            fprintf('Converting full color image to grayscale \n');
            data=object.Data;
            tones=size(data,3);
            switch tones
                case 3 % RGB color
                    r=data(:,:,1);
                    g=data(:,:,2);
                    b=data(:,:,3);
                case 4 % CMYK color
                    c=data(:,:,1);
                    m=data(:,:,2);
                    y=data(:,:,3);
                    k=data(:,:,4);
                    c=c*(1-k)+k;
                    m=m*(1-k)+k;
                    y=y*(1-k)+k;
                    % convert to RGB color
                    r=(1-c);
                    g=(1-m);
                    b=(1-y);
                otherwise
                    error('ERROR: invalid color model');
            end
            grayscale=0.2989*r+0.5870*g+0.1140*b; % convert to grayscale
            object.Data=grayscale;
            object.GraphicOptions.ColorMap=gray(64);
        case 'Full color'
            data=object.Data;
            tones=size(data,3);
            switch tones
                case 3 % RGB color
                    r=data(:,:,1);
                    g=data(:,:,2);
                    b=data(:,:,3);
                case 4 % CMYK color
                    fprintf('Converting CMYK color to RGB \n');
                    c=data(:,:,1);
                    m=data(:,:,2);
                    y=data(:,:,3);
                    k=data(:,:,4);
                    c=c*(1-k)+k;
                    m=m*(1-k)+k;
                    y=y*(1-k)+k;
                    % convert to RGB color
                    r=(1-c);
                    g=(1-m);
                    b=(1-y);
                otherwise
                    error('ERROR: invalid color model');
            end
            object.Data=cat(3,r,g,b);
            object.Legend={'R Image','G Image', 'B Image'};
            object.NumberImages=3;
            return
    end
end
%assert(ismatrix(object.Data),'ERROR: this class supports scalar data only');
object.Precision=object.Precision; % invoke superclass set.Precision method
    
end