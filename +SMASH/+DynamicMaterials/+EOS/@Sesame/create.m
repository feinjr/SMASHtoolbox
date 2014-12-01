function object=create(object,varargin)

Narg=numel(varargin);
assert(Narg>0,'Must Enter at least material number');
if Narg==1 % prompt user to select file
    [filename,pathname]=uigetfile({'*.*','All files'},'Select file');
    if isnumeric(filename)
        error('ERROR: no file selected');
    end
    material = varargin{1};
    filename=fullfile(pathname,filename);
    object=ImportFile(object,filename,material);
    
elseif (Narg==2) && ischar(varargin{2}) && isnumeric(varargin{1}) % filename, neos input
    filename = varargin{2};
    material = varargin{1};
    object=ImportFile(object,filename,material);

elseif (Narg==5) && isnumeric(varargin{1}) && isnumeric(varargin{2})    %Input tabular points directly
        %Define EOS table points
        assert(numel(varargin{1})==numel(varargin{2}),'Arrays are not consistent');
        object.Density=varargin{1};
        object.Temperature=varargin{2};
        object.Pressure=varargin{3};
        object.Energy=varargin{4};
        object.Entropy=varargin{5};

        %Set some properties
        %[~,name,ext]=fileparts(filename);  
        object.Name='Custom Sesame';
        object.Source = 'Input Table';
        object.SourceFormat='sesame';
        object=revealProperty(object,'SourceFormat');

elseif ischar(varargin{1}) && ischar(varargin{2})    %Create table based on reference curve
        object = CreateSesame(object,varargin{:});
else    
    error('ERROR: unable to create Signal with this input');
end
            